%% load and save data as CSV
% add SPM directories to path
addpath(genpath('/Applications/MatlabAddOns/SPM/'));
addpath(genpath('/Users/Psyche/spm12/'));
% clone canlabcore repository from github and add to path
addpath(genpath('/Users/Psyche/neurohack2018/predictive/CanlabCore/'));

% code from CanlabCore/CANlab_help_examples/published_html/canlab_dataset_basic_usage/canlab_dataset_basic_usage.html
% load pain dataset
load('Jepma_IE2_single_trial_canlab_dataset.mat');
print_summary(DAT)

% extract expectation and pain ratings, two continuous event-level variables from the object
[~, expect] = get_var(DAT, 'expected pain');
[~, pain] = get_var(DAT, 'reported pain');

% Make a multi-level scatterplot
create_figure('lines_expect_pain', 1, 2);
[han, Xbin, Ybin] = line_plot_multisubject(expect, pain, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors', custom_colors([1 .7 .4], [1 .7 .4], 100), 'gcolors', {[.4 .2 0] [.8 .4 0]});
axis tight
xlabel('Expectations'); ylabel('Pain'); set(gca, 'FontSize', 24);

% Now extract expectation and pain variables conditional on cue value:
[~, expect_cshigh] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' 1});
[~, expect_csmed] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' 0});
[~, expect_cslow] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' -1});
[~, pain_cshigh] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' 1});
[~, pain_csmed] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' 0});
[~, pain_cslow] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' -1});

% Now make the plot, without individual subject lines
% First set colors and condition names
color1 = {[.9 .4 .2] [.6 .3 0]};
color2 = {[.5 .5 .5] [.2 .2 .2]};
color3 = {[.4 .8 .4] [.2 .7 .2]};
condition_names = {'High Cue' 'Medium Cue' 'Low Cue'};

% Now plot:
subplot(1, 2, 2)
[han1, Xbin, Ybin] = line_plot_multisubject(expect_cshigh, pain_cshigh, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors', color1, 'center', 'noind', 'nolines');
[han2, Xbin, Ybin] = line_plot_multisubject(expect_csmed, pain_csmed, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors',color2, 'center', 'noind', 'nolines');
[han3, Xbin, Ybin] = line_plot_multisubject(expect_cslow, pain_cslow, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors',color3, 'center', 'noind', 'nolines');
xlabel('Expectations'); ylabel('Pain'); set(gca, 'FontSize', 24);
legend([han1.grpline_handle(1) han2.grpline_handle(1) han3.grpline_handle(1)], condition_names);
drawnow, snapnow

%% 