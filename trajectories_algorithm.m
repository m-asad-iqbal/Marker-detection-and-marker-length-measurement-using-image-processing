clear, clc, close all

source_dir = './Level 2 (Flow direction)'; % Number of trajectories 3 (Length Ratio)Flow direction
A = dir(strcat(source_dir, '/*.png'));

I = rgb2gray(imread(strcat(source_dir,'/', A(2).name)));
I_b = imbinarize(I);
[m, n] = size(I_b);

props_Ib = regionprops(I_b, 'all');
extents = [props_Ib.Extent];

dashes_ind = extents < 0.5;
dots_ind = extents >= 0.5;

dashes_img = ismember(bwlabel(I_b), find(dashes_ind));
dots_img = ismember(bwlabel(I_b), find(dots_ind));

dashes_props = regionprops(dashes_img, 'all');
dots_props = regionprops(dots_img, 'all');

dots_idx_all = {dots_props.PixelIdxList};
groups = zeros(size(I_b));
arrow_centers = [];

for i = 1:length(dashes_props)
    
    this_dash = ismember(bwlabel(dashes_img), i);
    groups = groups + i * this_dash;
    points = dashes_props(i).PixelList;
    X = points(:, 1); Y = points(:, 2);
    mdl = fitlm(X, Y);
    
    len_x = max(X) - min(X);
    x_range =  unique(min(max(min(X) - 3 * len_x:3*len_x + max(X), 1), m));
    pred_y = min(max(round(mdl.predict(x_range')), 1), n);
    
    interp_img = zeros(size(I_b));
    for ll = 1:length(pred_y)
        interp_img(pred_y(ll), x_range(ll)) = 1;
    end
    interp_img = bwmorph(interp_img, 'dilate', 1);
    mult_img = dots_img .* interp_img;
    
    props_mult_img = regionprops(mult_img, 'PixelIdxList');
    props_mult_img = [props_mult_img.PixelIdxList];
    
    dots_within = [];
    for this_dot = 1:length(dots_idx_all)
        
        dot_pixel_list = dots_idx_all{this_dot};
        dot_within = any(ismember(props_mult_img, dot_pixel_list));
        
        
        
        if dot_within
            dots_within = [dots_within, this_dot]; %#ok
        end
    end
    dots_within = sort(dots_within);
    if length(dots_within) > 2
        dots_within = dots_within(1:2);
    end
    
    these_dots = ismember(bwlabel(dots_img), dots_within);
    
    
    groups = groups + i * these_dots;
    
    for dd = 1:length(dots_within)
        dots_idx_all{dots_within(dd)} = [nan, nan];
    end
    
    this_dash_center = regionprops(this_dash,'Centroid');
    this_dash_center = [this_dash_center.Centroid];
    
    this_dot_center = regionprops(these_dots ,'Centroid');
    this_dot_center = cell2mat({this_dot_center.Centroid}');
    
    dist_1 = dist([this_dash_center; this_dot_center]');
    dist_1 = dist_1(2:end, 1);
    
    [~, ind_furthest] = max(dist_1);
    try
    arrow_centers = [arrow_centers; ...
        [this_dot_center(ind_furthest, :), this_dash_center]]; %#ok
    catch
    end
end
% dashes_orientation = [dashes_props.Orientation];


figure, imshow(I_b), impixelinfo
figure, imshowpair(dashes_img, dots_img)
figure, imshow(label2rgb(groups)), impixelinfo

%%
tic

result_image = zeros([size(groups), 3], 'double');
arrow_image = zeros([size(groups), 3], 'uint8');
num_groups = max(groups(:));
all_centroids = [];

for i = 1:num_groups
    try
    this_group = groups == i;
    this_group_closed = imclose(this_group, strel('disk', 50));
    
    cgroup_sub = bwmorph(and(~this_group, this_group_closed), 'open', 3);
    
    cgroup_box = bwmorph(bwmorph(this_group_closed, 'dilate', 1), 'remove');
    
    groups_props = regionprops(this_group);
    cgroups_props = regionprops(cgroup_sub);
    
    result_image = double(result_image) + double(this_group * 255);
    arrow_image = uint8(arrow_image) + uint8(this_group * 255);
    
    result_image = imoverlay(result_image, cgroup_box, 'r');
    result_image = insertMarker(result_image, ...
        cell2mat({groups_props.Centroid}'), 'x', 'size', 2, 'color', 'red');
    result_image = insertMarker(result_image, ...
        cell2mat({cgroups_props.Centroid}'), 'x', 'size', 1, 'color', 'green');
    
    arrow_image = draw_arrow_fcn(arrow_image, arrow_centers(i, :), len_x);
    
% %     all_centroids = [all_centroids; [groups_props.Centroid], ...
% %         [cgroups_props.Centroid]]; %#ok
    catch
    end
end
toc

figure, imshow(result_image), impixelinfo
% figure, imshowpair(dashes_img, dots_img)
figure, imshow(arrow_image), impixelinfo
