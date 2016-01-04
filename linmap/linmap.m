function vout = linmap(vin,varargin)
% LINMAP Applies linear mapping to a vector (or matrix) using the provided
% range.
%   VOUT = LINMAP(VIN, ROUT) Maps each value of the vector VIN into
%   new vector with range ROUT. The range of VIN is determined by 
%   [min(vin),max(vin)]. If VIN is a matrix, for each column the
%   appropriate mapping is computed.
%   VOUT = LINMAP(VIN, RIN, ROUT) Same as before but uses RIN as the range
%   of VIN
%   
%   Example:
%   >> v1 = linspace(0, 20, 5)
%   v1 = [0     5    10    15    20]
%   >> v2 = linmap(v1, [-5,5]);
%   v2 = [-5 -2.5 0 2.5 5]
%   >> v3 = linmap(v1, [0 40], [0 10]
%   v3 = [0 1.25 2.5 3.75 5]

%   Copyright (c) 2015, Edoardo Bezzeccheri
%   All rights reserved.

if nargin == 2
    a = min(vin);
    b = max(vin);   
    rout = varargin{1};
    n = ones(size(vin,1),1);
elseif nargin == 3
    rin = varargin{1};
    a = rin(1);
    b = rin(2);
    rout = varargin{2};
    n = ones(size(vin));
else
    error('Wrong number of args');
end

c = rout(1);
d = rout(2);
vout = (((c+d) + (d-c)*((2*vin - n*(a+b))./(n*(b-a)))))/2;
end