function [outEEG, eventtbl_epoch] = eeg_htpEegAdvancedEpochs(EEG, main_trigger, backup_trigger, epoch_length, varargin)
% Advanced epoching example for complex ERP paradigms
% Inputs:
% - EEG: input EEG SET file
% - main_trigger: cell array input for main trigger(s)
% - backup_trigger: cell array input for backup trigger(s)
% - epoch_length: cell array input for epoch length(s)
% Optional Inputs:
% - 'TimeUnit': time unit (default: 1e-3)
% - 'SaveCSV': whether to save the output as a CSV file (default: false)
% Outputs:
% - epochEEG: epoched EEG data
% - eventtbl_epoch: event table in CSV format (if 'SaveCSV' is true)

% Create input parser
p = inputParser;
addRequired(p, 'EEG');
addRequired(p, 'main_trigger', @iscell);
addRequired(p, 'backup_trigger', @iscell);
addRequired(p, 'epoch_length', @isnumeric);
addParameter(p, 'TimeUnit', 1e-3, @isnumeric);
addParameter(p, 'SaveCSV', false, @islogical);
addParameter(p, 'outputDir', pwd, @isfolder);
parse(p, EEG, main_trigger, backup_trigger, epoch_length, varargin{:});

% Convert events to user-friendly table
[eventout, fields] = eeg_eventformat(EEG.event, 'array');
eventtbl_raw = array2table(eventout, 'VariableNames', fields);

% Recreate new event table only using relevant columns
eventtbl = table(eventtbl_raw.trial_type, eventtbl_raw.Condition, eventtbl_raw.latency, 'VariableNames', {'type','condition', 'latency'});
eventtbl_select = eventtbl(ismember(eventtbl.type, [main_trigger, backup_trigger]),:);

% Get counts
stimcounts = cell2table(tabulate(eventtbl_select{:,'type'}), 'VariableNames', {'type','count','percentage'});
findCount = @(T, type) sum(table2array(T(ismember(T.type, type), 'count')));

% Error check if photosensor and stimulus counts match
% TODO: Add action logger for logging invalid photosensor data
%       Will "lag" condition to align with photosensor if sensor is valid
if(isequal(findCount(stimcounts, main_trigger), findCount(stimcounts, backup_trigger)))
    disp('Photo sensor data is valid.')
    valid_event = main_trigger;
    eventtbl_select.LaggedCondition = [eventtbl_select.condition(2:end); NaN];
else
    disp('# of DINs does not equal # of stimuli.');
    valid_event = backup_trigger;
    eventtbl_select.LaggedCondition = [eventtbl_select.condition(1:end)];
end
inevents =  eventtbl_select(ismember(eventtbl_select.type, valid_event),:);

% Create valid event structure
eventEEG = pop_importevent(EEG, 'event', [inevents.type inevents.latency inevents.LaggedCondition], 'fields', {'type','latency', 'condition'}, 'timeunit', p.Results.TimeUnit, 'append', 'no');

% Create epoched data
epochEEG = pop_epoch(eventEEG, valid_event, epoch_length, 'epochinfo', 'yes');

% Narrow down events
epochEEG2 = pop_selectevent(epochEEG, 'latency','-.1 <= .1','deleteevents','on');

% Query raw event table
[eventout_epoch, fields_epoch] = eeg_eventformat(epochEEG2.epoch, 'array',  {'type','latency','condition'});

% error checking for empty epochs
assert(~isempty(eventout_epoch), 'No epochs available - check event codes or timeunit.')

% Verify event conversion with table output
eventtbl_epoch = array2table(eventout_epoch, 'VariableNames', fields_epoch);

outEEG = epochEEG2;

% Save output as a CSV file
if p.Results.SaveCSV
    filename = [p.Results.outputDir, filesep EEG.filename(1:end-4) '_epoch_table.csv'];
    writetable(eventtbl_epoch, filename);
end

end
