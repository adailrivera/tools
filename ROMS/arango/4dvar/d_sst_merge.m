%
%  D_SST_MERGE:  Driver script to merge SST observations 4D-Var file.
%
%  This a user modifiable script that can be used to merge several
%  SST 4D-Var observations NetCDF files. It allows the user to merge
%  data from several instruments and process super observations.
%

% svn $Id: d_sst_merge.m 647 2013-01-22 23:40:00Z arango $
%===========================================================================%
%  Copyright (c) 2002-2013 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                           Hernan G. Arango        %
%===========================================================================%

%  Set input/output NetCDF files.

 my_root = '/Users/arango/ocean/repository/Projects';

 GRDfile = fullfile(my_root, 'wc13/Data', 'wc12_grd.nc');
 OBSfile = 'wc12_sst_obs.nc';
 SUPfile = 'wc12_sst_super_obs.nc';

%  Set input SST 4D-Var NetCDF file name(s).

 SST_dir = '/Users/arango/ocean/repository/Projects/wc13/OBS';

 SSTcell = {fullfile(SST_dir, 'AMSR_obs_20050101_20050131.nc'), ...
            fullfile(SST_dir, 'GOES_obs_20050101_20050131.nc'), ...
            fullfile(SST_dir, 'PFEG_obs_20050101_20050131.nc')};

%  Set time increment criteria, DT (days), for merging SST datasets. It
%  must be larger than ROMS application time-step.  Data that is
%  closer than DT will be combined.

DT=0.5;        % since we are dealing with dayly SST data

%---------------------------------------------------------------------------
%  Merge observations to a single observation structure.
%---------------------------------------------------------------------------

S=obs_merge(SSTcell,DT);

%---------------------------------------------------------------------------
%  Merged super observations.
%---------------------------------------------------------------------------

[OBS]=super_obs(S);

%  Meld inital observation error with the values computed when binning
%  the data into super observations. Take the larger value.

OBS.error = max(OBS.error, OBS.std);

%  Write new structure to a new NetCDF.

[status]=c_observations(OBS,SUPfile);

avalue='days since 1990-01-01 00:00:00 GMT';

[status]=nc_attadd(SUPfile,'units',avalue,'survey_time');
[status]=nc_attadd(SUPfile,'calendar','gregorian','survey_time');

[status]=nc_attadd(SUPfile,'units',avalue,'obs_time');
[status]=nc_attadd(SUPfile,'calendar','gregorian','obs_time');

[status]=obs_write(SUPfile,OBS);

disp(' ');
disp('Done.');
disp(' ');
