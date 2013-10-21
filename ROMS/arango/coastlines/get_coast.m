function [lon,lat]=get_coast(Llon,Rlon,Blat,Tlat,varargin)
  
%
% GET_COAST:  Extract coastline data from GSHHS database
%
% [lon,lat]=get_coast(Llon,Rlon,Blat,Tlat,OutFile,Resolution,GSHHS_dir)
%
% This function extracts coastline data from the Global Self-consistent,
% Hierarchical, High-resolution Shoreline (GSHHS) database for the box
% corners bounded by (Llon,Blat) and (Rlon,Tlat).
%
%                 ______ (Rlon, Tlat)
%                |      |
%                |      |
%                |______|
%    (Llon, Blat)    
%
% On Input:
%
%    Llon         Box left-edge   longitude (degrees, -180 - 180)
%
%    Rlon         Box right-edge  longitude (degrees, -180 - 180)
%
%    Blat         Box bottom-edge latitude  (degress,  -90 - 90 )
%
%    Tlat         Box top-edge    latitude  (degress,  -90 - 90 )
%
%    OutFile      Output extracted coastline file (Optional, string). The
%                   following values are possible:
%
%                   OutFile = []          no output file (default)
%                   OutFile = 'xxxx.mat'  SeaGrid Matlab file
%                   OutFile = 'xxxx.cst'  ROMS plotting package file
%
%    Resolution   GSHHS resolution database (Optional, string)
%
%                   'f' or 'full'         Full resolution
%                   'h' or 'high'         High resolution
%                   'i' or 'intermediate' Intermediate resolution (default)
%                   'l' or 'low'          Low resolution
%                   'c' or 'crude'        Crude resolution
%
%    GSHHS_dir    GSHHS database directory (Optional, string)
%
%                   GSHHS_DIR = '~/ocean/GSHHS/Version_1.2'  (default)
%
% On Ouput:
%
%    lon          Extracted coastline longitude       
%
%    lat          Extracted coastline latitude       
%
 
% svn $Id: get_coast.m 647 2013-01-22 23:40:00Z arango $
%===========================================================================%
%  Copyright (c) 2002-2013 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                           Hernan G. Arango        %
%===========================================================================%

% Set optional arguments

OutFile    = [];
Resolution = 'intermediate';
GSHHS_dir  = '~/ocean/GSHHS/Version_1.2';

switch numel(varargin)
 case 1
   OutFile    = varargin{1};
 case 2
   OutFile    = varargin{1};
   Resolution = varargin{2};
 case 3
   OutFile    = varargin{1};
   Resolution = varargin{2};
   GSHHS_dir  = varargin{3};
end

% Select GSHHS file according to specified resolution.

switch lower(Resolution),
  case {'f', 'full'}
    Cname = fullfile(GSHHS_dir, 'gshhs_f.b');
    name  = 'gshhs_f.b';
  case {'h', 'high'}
    Cname = fullfile(GSHHS_dir, 'gshhs_h.b');
    name  = 'gshhs_h.b';
  case {'i', 'intermediate'}
    Cname = fullfile(GSHHS_dir, 'gshhs_i.b');
    name  = 'gshhs_i.b';
  case {'l', 'low'}
    Cname = fullfile(GSHHS_dir, 'gshhs_l.b');
    name  = 'gshhs_l.b';
  case {'c', 'crude'}
    Cname = fullfile(GSHHS_dir, 'gshhs_c.b');
    name  = 'gshhs_c.b';
  otherwise
    Cname = fullfile(GSHHS_dir, 'gshhs_i.b');
    name  = 'gshhs_i.b';
end

% Set special value.

spval = 999.0;

%--------------------------------------------------------------------------
% Extract coastlines from GSHHS database.
%--------------------------------------------------------------------------

% Set default clipping type to replace points outside with nearest border
% point.  A NaN value is added everytime that a close polygon is found
% (continents, islands, lakes). This is what it is needed for SeaGrid or
% regular plotting in Matlab.

cliptype = 'patch';
 
if (~isempty(OutFile)),
  if (strfind(lower(OutFile), '.cst'))
    cliptype = 'on';                             % ROMS plotting package
  end
end

disp(['Reading GSHHS database: ',name]);

Coast = r_gshhs(Llon,Rlon,Blat,Tlat,Cname);

disp(['Processing read coastline data']);

C = x_gshhs(Llon,Rlon,Blat,Tlat,Coast,cliptype);

lon = C.lon;
lat = C.lat;

%---------------------------------------------------------------------------
%  Save extrated coastlines.
%---------------------------------------------------------------------------

if (~isempty(OutFile)),
  switch cliptype,
    case 'patch'
      save (OutFile,'lon','lat');
    case 'on'
      x = lon;
      y = lat;
      ind = find(isnan(x));
      if (~isempty(ind)),
        if (length(ind) == length(C.type)),
          x(ind) = C.type;
          y(ind) = spval;

% Cliping of out-of-range values failed. Try original values.
      
        elseif (length(ind) == length(Coast.type)), 
	  x(ind) = Coast.type;
          y(ind) = spval;
        else      
	  x(ind) = 1;
          y(ind) = spval;
        end
      end
      fid = fopen(OutFile,'w');
      if (fid ~= -1),
        for i=1:length(x),
          fprintf(fid,'%11.6f  %11.6f\n',y(i),x(i));
        end
        fclose(fid);
      end
  end
end

return
