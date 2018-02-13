[FileName,PathName,FilterIndex] = uigetfile({'*.VBO'; '*.csv'}, 'Pick the data file of interest'); %Choose file with GUI
full_path = strcat(PathName, FileName); %make full file path from path + filename
[fp,n, ext] = fileparts(full_path);
if (strcmpi(ext,'.VBO'))
   data = importdata(full_path, ' ', 70);
elseif (strcmpi(ext,'.csv'))
    data = importdata(full_path); %Get file into Matlab
end
%%
dat = data.data;
lat = dat(:,3)/60;
goodindices = lat > 0;
%%
dat=dat(goodindices,:);
time = dat(:,2)-dat(1,2);
lat = dat(:,3)/60;
lon = -dat(:,4)/60;
vel = dat(:,5);
alt = dat(:,7);
dist = pathdist(lat,lon, 'kilometers');
%%
plot(dist,alt);
[latlim, lonlim] = geoquadpt(lat, lon);
[latlim, lonlim] = bufgeoquad(latlim, lonlim, (max(lat) - min(lat)), ...
    (max(lon) - min(lon)));
figure;
usamap(latlim, lonlim)
geoshow(lat, lon, 'DisplayType', 'line')
%%
[latlim, lonlim] = geoquadpt(lat, lon);
[latlim, lonlim] = bufgeoquad(latlim, lonlim, (max(lat) - min(lat)), ...
    (max(lon) - min(lon)));
figure;
usamap(latlim, lonlim)
geoshow(lat, lon, 'DisplayType', 'line')
search = wmsfind('ortho');
layer = search.refineLimits('Latlim', latlim, 'Lonlim', lonlim);
[A, R] = wmsread(layer, 'Latlim', latlim, 'Lonlim', lonlim);
figure
usamap(A,R)
geoshow(A,R)
geoshow(lat, lon, 'DisplayType', 'line', 'Color', 'red', ...
    'Marker', 'diamond', 'MarkerEdgeColor', 'blue');