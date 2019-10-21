function [my_sphere,coords] = gen_sphere(radius)
% generates a 3D matrix that labels voxels as inside our outside a given
% radius.
%
    dim = 2*radius + 1; % size of box containing sphere
    mid = radius + 1; % midpoint of the box ([mid mid mid] is centroid)
    my_sphere = zeros(dim,dim,dim); % build box
    for i = 1:numel(my_sphere) % loop through each location in box
        [X,Y,Z] = ind2sub([dim,dim,dim],i); % get coordinates
        D = pdist([mid mid mid; X Y Z]', 'euclidean'); % distance from centroid
        if D <= radius % if less than radius, put in box
            my_sphere(i) = 1;
        end
    end
    
    % get coordinates and offset by center voxel
    [coords.x,coords.y,coords.z] = ind2sub(size(my_sphere), find(my_sphere));
    coords.x  = coords.x - mid;
    coords.y  = coords.y - mid;
    coords.z  = coords.z - mid;
end
