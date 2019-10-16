function [mni_coords, mni_labels, NN_flag] = nifti_values(coords_filepath,atlas_filepath)
% takes in a csv file where the first 3 columns are (x,y,z) MNI
% coordinates and an atlas file in mni space and outputs the atlas labels
% for the csv coordiantes.
%
% Test:
%   [mni_labels] = nifti_values('test_input.csv','AAL116.nii')
%
% Input:
%   csv_filepath (str): filepath to coordinate file organized (Nx3)
%   atlas_filepath (str): filepath to atlas file in MNI space (.gz unzip)
%
% Output:
%   mni_labels (double): atlas values at each given coordinate
%   NN_flag (double): flags coordinates where nearest neighbor was
%       indicated due to atlas value 0
%
% Thomas Campbell Arnold
% tcarnold@seas.upenn.edu
% 3/22/2019
%
% modifications
% 7/11/19 - changed dlmread to readtable, resolve string/numeric read error
% 10/16/19 - extracted gen_sphere subroutine and included as seperate function

% read in AAL image
V=niftiinfo(atlas_filepath); % get header
atlas = niftiread(V); % get 3D matrix
T=V.Transform.T; % get transformation matrix
T=T'; % transpose transformation matrix

% get mni coordinates from csv and transfer to matlab coordinate space
csv_coords = readtable(coords_filepath);
csv_coords = table2array(csv_coords(:,2:4)); % only get coordinates
mni_coords = mni2cor(csv_coords,T);

NN_flag = zeros(size(mni_coords,1), 2); % variable indicating no label initial found in atlas

% get AAL label based on coordinates
for i = 1:size(mni_coords,1)
    
    % assign initial value
    try
        mni_labels(i) = atlas(mni_coords(i,1), mni_coords(i,2), mni_coords(i,3));
    catch
        warning(['Problem with ',num2str(i),'th coordinate [',...
            num2str(mni_coords(i,1)),' ',num2str(mni_coords(i,2)),...
            ' ',num2str(mni_coords(i,3)),'].  Assigning a label of 0.']);
        mni_labels(i) = 0;
    end
    
    radius = 0; % initial radius size
    while mni_labels(i) == 0 % get mode of cubes until answer is achieved
        NN_flag(i,1) = 1; % store value indicating label not localizaed
        radius = radius + 1; % increase radius
        [my_sphere,coords] = gen_sphere(radius); % get coordinates to sample
        x = coords.x + mni_coords(i,1);
        y = coords.y + mni_coords(i,2);
        z = coords.z + mni_coords(i,3);
        
        % get sample values
        try
            ind = sub2ind(size(atlas),x,y,z); % convert to indices
        catch
            break % break if sampling reach boundary of box
        end
        
        
        sphere_vals = atlas(ind); % sample sphere
        [~,~,vals] = find(sphere_vals); % find nonzero and non-NaN values
        if vals % if there are nonzero values, update label
            mni_labels(i) = mode(vals(:)); % get mode
            NN_flag(i,2) = radius; % store distance to NN
        end
        
        % break while loop if radius is larger than 3 voxels
        if radius >= 3
            break
        end
        
    end
end

end