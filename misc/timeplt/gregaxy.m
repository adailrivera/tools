function []=gregaxy(jd,yeartic);
% GREGAXY Labels the current x-axis with Gregorian labels in units of years.
%      GREGAXY(JD,YEARTIC) draws Gregorian time labels on the x-axis in
%      intervals of YEARTIC days.

% Rich Signell
n=length(jd);

jd0_index = find(jd == gmin(jd));
jd0=jd(jd0_index(1));

jdn_index = find(jd == gmax(jd));
n = length(jdn_index);
jd1=jd(jdn_index(n));

start=gregorian(jd0);
stop=gregorian(jd1);

start=[start(1) 0 0 0 0 0];
stop=[stop(1)+1 0 0 0 0 0];
jd0=julian(start);
jd1=julian(stop);
%xlim=[jd0-180 jd1+180];
%set(gca,'xlim',xlim);  
ylim=get(gca,'ylim');  
%
year=[start(1):yeartic:stop(1)]';
n=length(year);
greg=[year ones(n,2) zeros(n,3)];
jdtic=julian(greg);

%
% find year labels
%
yearticlab=sprintf('%4.4d',year');
nyear=length(year);
yearticlab=reshape(yearticlab,4,nyear)';
set(gca,'xtick',jdtic,'Xticklabels',yearticlab)
xlabel('Year')
%
