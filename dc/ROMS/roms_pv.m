% calculates Ertel PV at interior RHO points (horizontal plane) and midway between rho points in the vertical
%       [pv] = roms_pv(fname,tindices)

function [pv,xpv,ypv,zpv] = roms_pv(fname,tindices,outname)

% parameters
%lam = 'rho';
vinfo = ncinfo(fname,'u');
s     = vinfo.Size;
dim   = length(s); 
slab  = roms_slab(fname,0)-3;

warning off
grid = roms_get_grid(fname,fname,1,1);
warning on

% parse input
if ~exist('tindices','var'), tindices = []; end

[iend,tindices,dt,~,stride] = roms_tindices(tindices,slab,vinfo.Size(end));

rho0  = ncread(fname,'R0');
tpv = ncread(fname,'ocean_time');
tpv = tpv([tindices(1):tindices(2)]);
f   = ncread(fname,'f',[1 1],[Inf Inf]);

xname = 'x_pv'; yname = 'y_pv'; zname = 'z_pv'; tname = 'ocean_time';

grid1.xv = repmat(grid.x_v',[1 1 grid.N]);
grid1.yv = repmat(grid.y_v',[1 1 grid.N]);
grid1.zv = permute(grid.z_v,[3 2 1]);

grid1.xu = repmat(grid.x_u',[1 1 grid.N]);
grid1.yu = repmat(grid.y_u',[1 1 grid.N]);
grid1.zu = permute(grid.z_u,[3 2 1]);

grid1.xr = repmat(grid.x_rho',[1 1 grid.N]);
grid1.yr = repmat(grid.y_rho',[1 1 grid.N]);
grid1.zr = permute(grid.z_r,[3 2 1]);

grid1.zw = grid.z_w;
grid1.s_w = grid.s_w;
grid1.s_rho = grid.s_rho;

%% setup netcdf file

if ~exist('outname','var') || isempty(outname), outname = 'ocean_pv.nc'; end
if exist(outname,'file')
    %in = input('File exists. Do you want to overwrite (1/0)? ');
    in = 1;
    if in == 1, delete(outname); end
end
try
    nccreate(outname,'pv','Dimensions', {xname s(1)-1 yname s(2)-2 zname s(3)-1 tname length(tpv)});
    nccreate(outname,xname,'Dimensions',{xname s(1)-1 yname s(2)-2 zname s(3)});
    nccreate(outname,yname,'Dimensions',{xname s(1)-1 yname s(2)-2 zname s(3)});
    nccreate(outname,zname,'Dimensions',{xname s(1)-1 yname s(2)-2 zname s(3)});
    nccreate(outname,tname,'Dimensions',{tname length(tpv)});
    
    ncwriteatt(outname,'pv','Description','Ertel PV calculated from ROMS output');
    ncwriteatt(outname,'pv','coordinates',[xname ' ' yname ' ' zname ' ' ocean_time]);
    ncwriteatt(outname,'pv','units','N/A');
    ncwriteatt(outname,xname,'units',ncreadatt(fname,'x_u','units'));
    ncwriteatt(outname,yname,'units',ncreadatt(fname,'y_u','units'));
    ncwriteatt(outname,zname,'units','m');
    ncwriteatt(outname,tname,'units','s');
    fprintf('\n Created file : %s\n', outname);
catch ME
    fprintf('\n Appending to existing file.\n');
end

%% calculate pv

misc = roms_load_misc(fname);

for i=0:iend-1
    [read_start,read_count] = roms_ncread_params(dim,i,iend,slab,tindices,dt);
    tstart = read_start(end);
    tend   = read_start(end) + read_count(end) -1;
    
    u      = ncread(fname,'u',read_start,read_count,stride);
    v      = ncread(fname,'v',read_start,read_count,stride);
    try
        rho = ncread(fname,'rho',read_start,read_count,stride); % theta
    catch ME
        rho = -misc.Tcoef*ncread(fname,'temp',read_start,read_count,stride);
        %fprintf('\n Assuming T0 = 14c\n');
    end
    
    [pv,xpv,ypv,zpv] = pv_cgrid(grid,u,v,rho,f,rho0);

    ncwrite(outname,'pv',pv,read_start); 
    
    % write now so that file is still usable in case of crash
    if i == 0
        ncwrite(outname,xname,xpv);
        ncwrite(outname,yname,ypv);
        ncwrite(outname,zname,zpv);
        ncwrite(outname,'ocean_time',tpv);
    end
    
    intPV(tstart:tend) = domain_integrate(pv,xpv,ypv,zpv);
    
end

save pv.mat pv xpv ypv zpv tpv intPV
fprintf('\n Wrote file : %s \n\n',outname);

    %% old code
    
%     pv1    = avgx(avgz(bsxfun(@plus,avgy(vx - uy),f)))  .*  (tz(2:end-1,2:end-1,:,:));
%     pv2    = (-1)*;
%     pv3    = uz.*avgz(tx);
    %pv = double((pv1 + avgy(pv2(2:end-1,:,:,:)) + avgx(pv3(:,2:end-1,:,:)))./avgz(lambda(2:end-1,2:end-1,:,:))); 