function [delay,weight] = driving_function_imp_wfs_ps(x0,nx0,xs,conf)
%DRIVING_FUNCTION_IMP_WFS_PS calculates the WFS weighting and delaying for a
%plane wave as source model
%
%   Usage: [delay,weight] = driving_function_imp_wfs_ps(x0,nx0,xs,[conf]);
%
%   Input parameters:
%       x0      - position  of secondary sources (m) [nx3]
%       nx0     - direction of secondary sources [nx3]
%       xs      - position of point source [nx3]
%       conf    - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       delay   - delay of the driving function (s)
%       weight  - weight (amplitude) of the driving function
%
%   DRIVING_FUNCTION_IMP_WFS_PS(x0,nx0,xs,conf) returns delays and weights for
%   the WFS driving function for a point source as source model.
%
%   see also: wave_field_imp, wave_field_imp_wfs, driving_function_mono_wfs_ps

%*****************************************************************************
% Copyright (c) 2010-2013 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013      Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 3;
nargmax = 4;
narginchk(nargmin,nargmax);
isargmatrix(x0,nx0,xs);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end


%% ===== Configuration ==================================================
% Speed of sound
c = conf.c;
xref = position_vector(conf.xref);
fs = conf.fs;
dimension = conf.dimension;


%% ===== Computation =====================================================

% Get the delay and weighting factors
if strcmp('2D',dimension)
    to_be_implemented;
elseif strcmp('2.5D',dimension)
    % Reference point
    xref = repmat(xref,[size(x0,1) 1]);
    % 2.5D correction factor
    %        ______________
    % g0 = \| 2pi |xref-x0|
    %
    g0 = sqrt(2*pi*vector_norm(xref-x0,2));
    % --------------------------------------------------------------------
    % d_2.5D using a point source as source model
    %
    %                        g0  <(x0-xs),n(x0)>
    % d_2.5D(x0,t) = h(t) * --- ---------------- delta(t - (1/c |x0-xs|))
    %                       2pi  |x0-xs|^(3/2)
    %
    % '*' denotes the convolution and <,> the scalar product. If there
    % is no sign between two arguments then it is a simple multiplication.
    %
    % r = |x0-xs|
    r = vector_norm(x0-xs,2);
    % Delay and amplitude weight
    delay = 1/c .* r;
    weight = g0/(2*pi) .* vector_product(x0-xs,nx0,2) ./ r.^(3/2);

elseif strcmp('3D',dimension) 
    % 3D: no correction factor necessary
    %
    % weights and surface weights for 3D grid
%     surface_weights = x0(:,4);
%     weights = x0(:,5);
    surface_weights = cos(x0(:,3) / norm(x0(:,1:3)));
    % use only the first 3 rows of x0. Theses are the x-,y-,z-coordinates.
    x0 = x0(:,1:3);
    %
    % d_3D using a point source as source model
    %
    %                 <(x0-xs),n(x0)>   /    1       1   d  \ 
    % d_3D(x0,t) = 2 ----------------- |  ------- + --- ---- | delta(t - (1/c |x0-xs|))
    %                    |x0-xs|^2      \ |x0-xs|    c   dt /
    % 
    %  <,> denotes the scalar product. If there
    %  is no sign between two arguments then it is a simple multiplication.
    %
    % r = |x0-xs|
    r = vector_norm(x0-xs,2);
    % Delay and amplitude weight
    delay = r./c;
    weight = (2.*vector_product(x0-xs,nx0,2)./(r.^2)).*(1./r + 1/c).*...
             surface_weights;
    
else
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end
