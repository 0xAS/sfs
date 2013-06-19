function [D] = driving_function_mono_wfs_3d(x0,xs,src,f,conf)
%DRIVING_FUNCTION_MONO_WFS_3D returns the driving signal D for 3D WFS
%
%   Usage: D = driving_function_mono_wfs_3d(x0,xs,src,f,[conf])
%
%   Input parameters:
%       x0          - position and direction of the secondary source (m)
%       xs          - position of virtual source or direction of plane wave (m)
%       src         - source type of the virtual source
%                         'pw' - plane wave (xs is the direction of the
%                                plane wave in this case)
%                         'ps' - point source
%                         'fs' - focused source
%       f           - frequency of the monochromatic source (Hz)
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal (nx1)
%
%   DRIVING_FUNCTION_MONO_WFS_3D(x0,xs,f,src,conf) returns the
%   driving signal for the given secondary source and desired source type (src).
%   The driving signal is calculated for the WFS 3 dimensional case in the
%   temporal domain.
%
%   References:
%       Spors2009 - Physical and Perceptual Properties of Focused Sources in
%           Wave Field Synthesis (AES127)
%       Spors2010 - Analysis and Improvement of Pre-equalization in
%           2.5-Dimensional Wave Field Synthesis (AES128)
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: plot_wavefield, wave_field_mono_wfs_3d,
%             driving_function_imp_wfs_3d

%*****************************************************************************
% Copyright (c) 2010-2012 Quality & Usability Lab                            *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
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

% AUTHOR: Hagen Wierstorf
% $LastChangedDate: 2012-06-14 11:03:36 +0200 (Thu, 14 Jun 2012) $
% $LastChangedRevision: 761 $
% $LastChangedBy: wierstorf.hagen $


%% ===== Checking of input  parameters ==================================
nargmin = 4;
nargmax = 5;
error(nargchk(nargmin,nargmax,nargin));
% isargsecondarysource(x0);
isargposition(xs);
xs = position_vector(xs);
isargpositivescalar(f);
isargchar(src);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end

%% ===== Configuration ==================================================
% phase of omega
phase = conf.phase;
% xref
xref = position_vector(conf.xref);
% Speed of sound
c = conf.c;

%% ===== Computation ====================================================

% Calculate the driving function in time-frequency domain

% Omega
omega = 2*pi*f;
x0_all = x0;
% Initialize empty driving function
D = zeros(size(x0_all,1),1);
% Loop through secondary sources
for ii = 1:size(x0_all,1)

    % Direction and position of secondary sources
    nx0 = x0_all(ii,4:6);
    x0 = x0_all(ii,1:3);
    % surface weights
    surfaceWeights = cos(x0(:,3) / norm(x0(:,1:3)));
    

    if strcmp('pw',src)

        % ===== PLANE WAVE ===============================================
        % Use the position of the source as the direction vector for a plane
        % wave
        nxs = xs / norm(xs);
        %
        % ----------------------------------------------------------------
        % D_3D using a plane wave as source model                                      
        %                                 i w 
        % D_3D(x0,w) =  -2 <n(xs),n(x0)>  ---  e^(-i w/c <n(xs),x0>) .* weights
        %                                  c
        %
        % NOTE: the phase term e^(-i phase) is only there in order to be able to
        %       simulate different time steps
   
        D(ii) = -2*nxs*nx0'./c * 1i*omega * exp(-1i*omega/c*(nxs*x0')).*...
                 surfaceWeights; 
             
        elseif strcmp('ps',src)
        % ===== POINT SOURCE ===========================================
        %
        % ----------------------------------------------------------------
        % D_3D using a point source as source model
        %
        % D_3D(x0,w) =
        %                    
        %  /  i w      1    \  -2 <(x0-xs),nx0>
        %  |  --- + ------- |  ---------------- e^(-i w/c |x0-xs|) .* weights
        %  \   c    |x0-xs| /      |x0-xs|^2
        %
        % ----------------------------------------------------------------
    
            D(ii) =  -2*(x0-xs)*nx0' / norm(x0-xs).^2 *(1/norm(x0-xs)+1i*omega/c)*...
                     exp(-1i*omega/c*norm(x0-xs)).*surfaceWeights; 
 
        elseif strcmp('fs',src)
        % ===== FOCUSED SOURCE ===========================================
        %
        % ----------------------------------------------------------------
        % D_3D using a point sink as source model
        %
        % D_3D(x0,w) =
        %                    
        %  /  i w      1    \  -2 <(x0-xs),nx0>
        %  |- --- + ------- |  ---------------- e^(i w/c |x0-xs|) .* weights
        %  \   c    |x0-xs| /      |x0-xs|^2
        %
        % ----------------------------------------------------------------

            D(ii) =  -2*(x0-xs)*nx0' ./ norm(x0-xs)^2 *(1./norm(x0-xs)-1i*omega./c)*...
                     exp(1i*omega./c*norm(x0-xs)).*surfaceWeights;

    end
        
end
% Add phase to be able to simulate different time steps
D = D .* exp(-1i*phase);
