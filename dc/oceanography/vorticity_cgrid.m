%       [vor,xvor,yvor,zvor] = vorticity_cgrid(grid,u,v)
% supply grid structure with 
%       xu,yu,zu & xv,yv,zv & xr,yr,zr
% IMPORTANT: Vorticity is calculated at the corners of grid cells. (lon/lat_psi)

function [vor,xvor,yvor,zvor] = vorticity_cgrid(grid,u,v,toUTM,plot_fig)
    
    if ~exist('toUTM','var'), toUTM = 0; end
    if ~exist('plot_fig','var'), plot_fig = 0; end
    
    vx    = bsxfun(@rdivide,diff(v,1,1),diff(grid.xv));
    uy    = bsxfun(@rdivide,diff(u,1,2),diff(grid.yu'));
    
    if toUTM
        mx = mean(grid.xv);
        my = mean(grid.yv);
        
        vx = vx./abs(sw_dist([my my],[mx mx+1],'km')*1000);
        uy = uy./abs(sw_dist([my my+1],[mx mx],'km')*1000);
    end
    
    vor  = vx - uy;
    
    xvor = avgx(grid.xv);
    yvor = grid.yv;
    zvor = avgx(permute(grid.zv,[3 2 1]));
    
    if plot_fig
        cmap = cbrewer('div','RdYlGn',32);
        fontSize = [10 12 14];
        figure
        subplot(121)
        pcolorcen(xvor,yvor,vx');
        colorbar('Southoutside');
        set(gca,'yDir','normal');
        beautify(fontSize); box on
        title('v_x')
        Z_dar
        colormap(cmap);
        cax = caxis;
        subplot(122)
        pcolorcen(xvor,yvor,uy'); 
        colorbar('Southoutside');
        caxis(cax);
        set(gca,'yDir','normal');
        Z_dar
        colormap(cmap);
        title('u_y');
        beautify(fontSize); box on
    end
    
 function [um] = avgy(um)
    um = (um(:,1:end-1,:,:)+um(:,2:end,:,:))/2;

function [um] = avgx(um)
    um = (um(1:end-1,:,:,:)+um(2:end,:,:,:))/2;

function [um] = avgz(um)
    um = (um(:,:,1:end-1,:)+um(:,:,2:end,:))/2;