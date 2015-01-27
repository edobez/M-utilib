function files = SaveFigs(varargin)
%SAVEFIGS Save open figures to files.
%   SAVEFIGS() saves all the opened figures into the folder ".\fig" in PNG
%   format.
%
%   F = SAVEFIGS() returns a cell array containing the list of the created
%   files (in relative path).
%   
%   SAVEFIGS(DIR) saves  all the opened figures into the folder specified 
%   in DIR as relative path in PNG format.
%
%   SAVEFIGS(DIR,options) saves  all the opened figures into the folder 
%   specified in DIR as relative path with options specified as Param/Value
%   pairs.
%   Options:
%   - 'format'  export format, between PNG (default), JPG, FIG 
%   - 'style'   name of the custom export style, created in
%       Figure:File->Export Setup
%   
%   Notes: If the default or specified folder is not present, it will be
%   created. In case a file with the same name is present in the folder,
%   the new file will be created with a trailing progressive number, in
%   order not to overwrite it.

% Copyright 2015 Edoardo Bezzeccheri
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%    http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

% Get the graphic root handler and check if there are figures open
root = groot;
figures = root.Children;
assert(~isempty(figures),'No open figures!');

% Initialize the input argument parser
p = inputParser;
defaultDir = 'fig';
defaultFormat = 'png';
expectedFormats = {'png','fig','jpg'};%TODO: add more formats
defaultStyle = '';

addOptional(p,'dir',defaultDir,@isstr);
addParameter(p,'format',defaultFormat,...
    @(x) any(validatestring(x,expectedFormats)));
addParameter(p,'style',defaultStyle,@isstr);

parse(p,varargin{:});

figdir = p.Results.dir;
if(isdir(figdir))
    disp('Folder already present, saving there');
else
    mkdir(figdir);
    disp(['Created folder ' figdir]);
end


for i=1:length(figures);
    % File name creation
    filepath = createFilename(figures(i),figdir);
    
    % Changing style (if needed)
    if (~isempty(p.Results.style))
        style = hgexport('readstyle',p.Results.style);
        hgexport(figures(i),'temp_dummy',style,'applystyle', true);
    end
    
    % Saving file
    switch p.Results.format
    case 'png'
        filepath = checkFilename([filepath '.png']);
        print(figures(i),'-dpng',filepath);
    case 'fig'
        filepath = checkFilename([filepath '.fig']);
        savefig(figures(i),filepath);
    case 'jpg'
        filepath = checkFilename([filepath '.jpg']);
        print(figures(i),'-djpeg',filepath);
    end
    
    % Reverting to factory style (only if a style was indicated)
    if (~isempty(p.Results.style))
        style = hgexport('factorystyle');
        hgexport(figures(i),'temp_dummy',style,'applystyle', true);
    end
    
    % Returning paths
    files{i} = filepath;
end

end

% TODO: this functions must return just the name, without the directory
function [filepath] = createFilename(fig,figdir)
    isnamevalid = @(x) isempty(regexp(x, '[/\*:?"<>|]', 'once'));
    
    figname = fig.Name;
    fignum = fig.Number;
    filepath = ['.' filesep figdir filesep];
    
    % TODO: add optional param for setting default name of fig
    if(~isnamevalid(figname) || isempty(figname))
        figname = ['fig' num2str(fignum)];
        warning('Figure (%d) has empty or invalid name for file creation. Using its number instead.',...
            fignum);
    end
    filepath = [filepath figname];    
end

% Recursive function needed for checking if there is another file with the
% same name. In that case it will add a number at the end.
function [filepath] = checkFilename(filepath,varargin)

    [dir,name,ext] = fileparts(filepath);
    filejoin = @(dir,name,ext) [dir filesep name ext]; % TODO: use fullfile function
    
    if (nargin == 2)
        rec = varargin{1};
        
        k = strfind(name,'-');
        namesplit = name(1:k(end)-1);
    else 
        rec = 1;
        namesplit = name;
    end
    
    filepath = filejoin(dir,name,ext);
    if(exist(filepath,'file') == 2)
        name = [namesplit '-' num2str(rec)];
        filepath = checkFilename(filejoin(dir,name,ext),rec+1);
        
        if(rec == 1) 
            warning('File with same (%s) name present in the chosen directory. Using unique name.',...
        [namesplit ext]);
        end
    end
    
end