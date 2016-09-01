function condense_image_folders(across)

if nargin < 1
    across = false;
end

new_folder = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/images/condensed';
start_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/images/nf_transfer_images';

if across == false

    sets = only_folders(rid_super_sub_folder_references(dir(start_dir)));

    for i = 1:length(sets)
        folder_path = fullfile(start_dir,sets(i).name);

        folder_struct = only_folders(rid_super_sub_folder_references(dir(folder_path)));
        foldernames = {folder_struct(:).name}';

        for k = 1:length(foldernames)
            condensed_folder = fullfile(new_folder,foldernames{k});
            if exist(condensed_folder,'dir') ~= 7
                mkdir(condensed_folder);
            end

            source_image_folder_path = fullfile(start_dir,sets(i).name,foldernames{k});
            cd(source_image_folder_path);

            imgs = dir('*.jpg');

            for j = 1:length(imgs)
                source_path = fullfile(source_image_folder_path,imgs(j).name);
                destin_path = fullfile(condensed_folder,imgs(j).name);

                if exist(destin_path,'file') == 2
                    fprintf('\nSkipping ...');
                else
                    copyfile(source_path,destin_path);
                end
            end

        end

    end
end

if across == true
    across_all_categories()
end

end

function across_all_categories()

    new_folder = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/images/condensed_across_categories';
    start_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/images/condensed';

    categories = only_folders(rid_super_sub_folder_references(dir(start_dir)));
    
    for i = 1:length(categories)
        category_path = fullfile(start_dir,categories(i).name);
        
        cd(category_path);
        
        imgs = dir('*.jpg');
        
        for j = 1:length(imgs)
            source_path = fullfile(category_path,imgs(j).name);
            destin_path = fullfile(new_folder,lower(imgs(j).name));
            
            if exist(destin_path,'file') == 2
                fprintf('\nSkipping ...');
            else
                copyfile(source_path,destin_path);
            end
            
        end
    end
    
end

