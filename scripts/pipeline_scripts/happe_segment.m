% happe_segment() - A helper script for HAPPE that segments the data
%                   according to user-specification and paradigm. Does not
%                   work on data that has already been segmented.
%
% Usage: 
%   >> EEG = happe_segment(EEG, params)
%
% Inputs:
%   EEG    - The EEG, in EEGLAB (Delorme & Makeig, 2004) format, to
%            segment.
%   params - The struct containing all the relevent information for 
%            segmentation, including segmentation bounds.
%
% Outputs:
%   EEG    - The EEG, in EEGLAB (Delorme & Makeig, 2004) format, after 
%            segmentation.
%
% Author: L.J. Gabard-Durnam, PINE Lab at Northeastern University, 2021
%         A.D. Monachino, PINE Lab at Northeastern University, 2022
%
% This file is part of HAPPE.
% Copyright 2018, 2021 Alexa Monachino, Kelsie Lopez, Laurel Gabard-Durnam
%
% HAPPE is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
% 
% HAPPE is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
% details.
% 
% You should have received a copy of the GNU General Public License along
% with HAPPE. If not, see <https://www.gnu.org/licenses/>.

function EEG = happe_segment(EEG, params,curr_file)
if EEG.trials == 1
    fprintf('Segmenting...\n') ;
    % TASK/ERP - SEGMENT USING TAGS
    if params.paradigm.task
        % For ERPs, adjust the event latencies by the user-specified
        % offset.%YB commented because offsets were already dealt with in
        % beapp formatting
%         if params.paradigm.ERP.on
%             if length(params.segment.offset)>1
%                 sampOffset = EEG.srate*params.segment.offset/1000 ; 
%             elseif length(params.segment.offset) == 1
%                 sampOffset = EEG.srate*params.segment.offset/1000 ; 
%             end
% 
%             %yb commented out bc already offset during beapp formatting
% %             for i = 1:size(EEG.event, 2); EEG.event(i).latency = ...
% %                     EEG.event(i).latency + sampOffset ; end
%         end
%           
     %   
        % Try segmenting the data using user-specified tags, catching any
        % errors that occur in the process. If unable to find any of the
        % tags, will throw a specific error to help the user troubleshoot.
        try
            EEG = pop_epoch(EEG, params.paradigm.onsetTags, ...
                [params.segment.start, params.segment.end], 'verbose', ...
                'yes');% 'epochinfo', 'yes') ;
        catch ME
            if strcmp(ME.message, ['pop_epoch(): empty epoch range (no ' ...
                    'epochs were found).'])
                error('HAPPE:noTags', ['ERROR: No specified event/onset ' ...
                    'tags in the data.']) ;
            else; rethrow(ME) ;
            end
        end
        
    % BASELINE/RESTING - SEGMENT USING LENGTH: Use the user-specified
    % segment length to epoch the data.
    else; EEG = eeg_regepochs(EEG, 'recurrence', params.segment.length, ...
            'limits', [0 params.segment.length], 'rmbase', [NaN]) ;
    end
else; fprintf('Cannot segment data that has already been segmented.\n') ;
end
end