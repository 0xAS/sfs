function varargout = sound_field_imp_line_source(X,Y,Z,xs,varargin)
%SOUND_FIELD_IMP_LINE_SOURCE simulates a sound field for a line source
%
%   Usage: [P,x,y,z] = sound_field_imp_line_source(X,Y,Z,xs,t,[conf])
%
%   Input parameters:
%       X           - x-axis / m; single value or [xmin,xmax]
%       Y           - y-axis / m; single value or [ymin,ymax]
%       Z           - z-axis / m; single value or [zmin,zmax]
%       xs          - position of line source / m
%       t           - time / samples
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       P           - Simulated sound field
%       x           - corresponding x axis / m
%       y           - corresponding y axis / m
%       z           - corresponding z axis / m
%
%   SOUND_FIELD_IMP_LINE_SOURCE(X,Y,Z,xs,t,conf) simulates a sound
%   field of a line source positioned at xs.
%   To plot the result use plot_sound_field(P,x,y,z).
%
%   References:
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: sound_field_imp, plot_sound_field, sound_field_mono_line_source

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
nargmin = 5;
nargmax = 6;
narginchk(nargmin,nargmax);
isargxs(xs);


%% ===== Computation ====================================================
[varargout{1:nargout}] = sound_field_imp(X,Y,Z,[xs 0 -1 0 1],'ls',1,varargin{:});
