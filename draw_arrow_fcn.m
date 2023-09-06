function arrow_image = draw_arrow_fcn(I, arrow_centers, x_len)
xo = arrow_centers(1);
yo = arrow_centers(2);
xt = arrow_centers(3);
yt = arrow_centers(4);

ar_angle = atand((yt - yo) ./ (xt - xo));

tip_dist = x_len / 1.5;


% for ii = 0:0.01:1% 1:90
tip_angle = 180 - 20;

xt1 = xt + (tip_dist*cos(pi/180 * (ar_angle + tip_angle)));%  
yt1 = yt + (tip_dist*sin(pi/180 * (ar_angle + tip_angle)));% ar_angle - 

xt2 = xt - (tip_dist*cos(pi/180 * (ar_angle + 180 - tip_angle)));
yt2 = yt - (tip_dist*sin(pi/180 * (ar_angle + 180 - tip_angle)));

%%
arrow_points = [arrow_centers, [xt, yt, xt1, yt1, xt2, yt2, xt, yt]]; %
arrow_image = insertShape(uint8(I), 'line', arrow_points, 'Opacity', 1, ...
    'color', 'blue', 'lineWidth', 1, 'SmoothEdges', false);
arrow_image = imfill(arrow_image, 'holes');