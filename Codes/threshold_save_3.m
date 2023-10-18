%% the below codes used for correction of multi-comparison and plot the stat-img on surf
%% codes based on canlabcore tools and BrainNet view

clc; close all; clear EC;
%% Necessary variables
fpath_stat = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\stats_2nd-level\Rob_reg_results';
id_subsets = {...
    'A-C', ...
    'Adults', ...
    'Children_ageG\Age_6_7', ...
    'Children_ageG\Age_8', ...
    'Children_ageG\Age_9', ...
    'Children_ageG\Age_10', ...
    'Children_ageG\Age_11_12'};
id_robregs = {'robust0001', 'robust0002', 'robust0003'};
id_cons    = {'ift', 'win', 'los'};
names_cons = {'inflation', 'win', 'loss'  };

plot_surf  = 1;
if plot_surf==1
   addpath(genpath('D:\matTools\BrainNet-Viewer-master'))
   % Config file and other necessary files(e.g. surface file):
   MapCfg = 'D:\matTools\BrainNet-Viewer-master\BrainNet_MapCfg.mat'; 
   Surf   = 'D:\matTools\BrainNet-Viewer-master\Data\SurfTemplate\BrainMesh_ICBM152_smoothed.nv';
   Node   = '';
   Edge   = '';
   folder_figs = 'E:\ImportantDOCs\currentWKdir\work_postdoc\BART_supplement\stats_2nd-level\Figs'; 
end

%% correction and save corrected-images

for n_subset=1:1  %numel(id_subsets)
    
    folder_subset = fullfile(fpath_stat, id_subsets{1,n_subset});
    
    for n_robreg=1:numel(id_robregs)
        fpath_setup = fullfile(folder_subset, id_robregs{1,n_robreg}, 'SETUP.mat');
        load(fpath_setup);
        [n,k]=size(SETUP.X);
        SETUP.X = SETUP.X(:, 2:end);
        
        % judge whether the contrast is two-sample based;
        % if two-sample, the first tmap(i.e.'*_0001.nii') is intercept effect;
        % otherwise, the first tmap is one-sample based;
        if sum(unique(SETUP.X(:,1)))==0
           fpath_tmap = fullfile(folder_subset, id_robregs{1,n_robreg}, 'rob_tmap_0002.nii');
        else
           fpath_tmap = fullfile(folder_subset, id_robregs{1,n_robreg}, 'rob_tmap_0001.nii'); 
        end
        
        t = statistic_image(fpath_tmap, 'type', 't', 'dfe', n-k);
        t_corr = threshold(t, 0.05, 'fdr', 'k', 10);
        
        if contains(id_subsets{1,n_subset}, '\')
           id_subsets{1,n_subset} = strrep(id_subsets{1,n_subset}, '\', '-'); 
           img_name=['tmap-', id_subsets{1, n_subset}, '_con-', names_cons{1,n_robreg}, '_corr-fdr05.nii'];
        else
           img_name=['tmap-', id_subsets{1, n_subset}, '_con-', names_cons{1,n_robreg}, '_corr-fdr05.nii'];
        end
        fname = fullfile(folder_subset, id_robregs{1,n_robreg}, img_name);
        
        write(...
                t_corr, ...
                'thresh', ...
                'fname', fname, ...
                'overwrite')
        
        if plot_surf==1
           % nii-img/volume file and Image name to save:
           VolumeFile = fname;
           OutputFile = fullfile(folder_figs, [img_name(1,1:end-4), '.png']); 
           load(MapCfg); 

           % change configuration of plotting according to type of stat-img(two-sample OR
           % one-sample statistic):
           vol = spm_read_vols(spm_vol(VolumeFile));
           if sum(unique(SETUP.X(:,1)))==0
              EC.vol.display = 1;
              EC.vol.color_map = 1;     % AFNI
              EC.vol.px = max(vol(:));
              EC.vol.pn = 0;
              EC.vol.nx = min(vol(:));
              EC.vol.nn = 0;
           else
              EC.msh.boundary = 1;
              EC.vol.display = 2;
              EC.vol.color_map = 3;     % AFNI_pos
              EC.vol.px = max(vol(:));
              if max(vol(:)) == 0
                 EC.vol.px = 0.1;
                 EC.vol.pn = 0.01;
              else
                 EC.vol.pn = 0.001;
              end
              EC.vol.nx = [];
              EC.vol.nn = [];
           end
           save(MapCfg, 'EC');
           % BrainNet mapping:
           BrainNet_MapCfg(Surf, VolumeFile, MapCfg, OutputFile); 
        end
        
    end
end 

%%
%% Change the names of statistical contrasts(if necessary):
%%
for n_subset=1:numel(id_subsets)
    
    folder_subset = fullfile(fpath_stat, id_subsets{1,n_subset});
    
    for n_robregs=1:numel(id_robregs)
        fpath_setup = fullfile(folder_subset, id_robregs{1,n_robregs}, 'SETUP.mat');
        load(fpath_setup);
        SETUP.name = id_cons{1,n_robregs};
        save(fpath_setup, 'SETUP')
    end
    
end
