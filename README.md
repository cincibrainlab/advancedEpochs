# eeg_htpEegAdvancedEpochs()
eeg_htpEegAdvancedEpochs is a MATLAB function for advanced epoching of EEG data. It can be used for complex ERP paradigms and is designed to work with EEG SET files. The function uses event table data to create epoched EEG data.

## Note: active development

## Installation
To use htpEegAdvancedEpochs, simply copy the function file to your MATLAB working directory.

## Usage
htpEegAdvancedEpochs requires an EEG SET file as input, as well as several other parameters:

main_trigger: cell array input for main trigger(s) (i.e. photocell)
backup_trigger: cell array input for backup trigger(s) (i.e. program trigger)
epoch_length: cell array input for epoch length(s)
There are also two optional input parameters:

if main trigger does not equal backup trigger, backtrigger is used.

'TimeUnit': time unit (default: 1e-3)
'SaveCSV': whether to save the output as a CSV file (default: false)
Here is an example usage:

[epochEEG, eventtbl_epoch] = htpEegAdvancedEpochs(EEG, {'DIN3'}, {'ch1+', 'ch2+'}, [-0.1 0.4], 'TimeUnit', 1e-3, 'SaveCSV', true);
This will create epoched EEG data and an event table in CSV format. The output will also be saved as a CSV file in the same directory as the EEG SET file.

## Contributing
Contributions to htpEegAdvancedEpochs are welcome. Please fork the repository and create a pull request.

## License
This project is licensed under the MIT License.
