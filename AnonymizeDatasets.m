function AnonymizeDatasets(varargin)
% AnonymizeDatasets scans a folder for TomoTherapy patient archives. For
% each archive found, the patient's name and MRN are removed, and the
% folder is renamed.  Patient names/folders will be renamed incrementally
% (Anon_0001, Anon_0002, etc). Note, the original and new archive names 
% are recorded using the Event() function to the file log.txt. Therefore, 
% to remove any connection of the original and anonymized archives, this 
% file should be deleted following execution.
%
% WARNING: THIS WILL MODIFY ALL PATIENT ARCHIVES, RENDERING THEM UNABLE TO
% RESTORE BACK TO A TOMOTHERAPY DATABASE.
%
% The following variables are required for proper execution: 
%   varargin{1}: folder to search for archives (relative to the MATLAB
%       path)
%   varargin{2} (optional): integer to use for renaming patients.  The 
%       count will start with this integer, and increment by one for each
%       subsequent archive found.  If not included, the count will start at
%       one.
% 
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2014 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Retrieve counter, if provided
if nargin == 2
    count = varargin{2};
else
    count = 1;
end

%% Start scanning for archives
% Note beginning execution
Event(['AnonymizeDatasets beginning search of ', varargin{1}, ...
    ' for patient archives']);

% Start timer
tic;

% Retrieve folder contents of input directory
folderList = dir(varargin{1});

% Initialize folder counter
i = 0;

% Start recursive loop through each folder, subfolder
while i < size(folderList, 1)
    
    % Increment current folder being analyzed
    i = i + 1;
    
    % If the folder content is . or .., skip to next folder in list
    if strcmp(folderList(i).name,'.') || strcmp(folderList(i).name,'..')
        continue
        
    % Otherwise, if the folder content is a subfolder    
    elseif folderList(i).isdir == 1
        
        % Retrieve the subfolder contents
        subFolderList = dir(fullfile(varargin{1}, folderList(i).name));
        
        % Randomize order of subfolder list
        subFolderList = subFolderList(randperm(size(subFolderList, 1)), :);
        
        % Look through the subfolder contents
        for j = 1:size(subFolderList, 1)
        
            % If the subfolder content is . or .., skip to next subfolder 
            % in list
            if strcmp(subFolderList(j).name, '.') || ...
                    strcmp(subFolderList(j).name, '..')
                continue
            else
                % Otherwise, replace the subfolder name with its full
                % reference
                subFolderList(j).name = fullfile(folderList(i).name, ...
                    subFolderList(j).name);
            end
        end
        
        % Append the subfolder contents to the main folder list
        folderList = vertcat(folderList, subFolderList); %#ok<AGROW>
        
        % Clear temporary variable
        clear subFolderList;
        
    % Otherwise, if the folder content is a patient archive
    elseif size(strfind(folderList(i).name, '_patient.xml'), 1) > 0
    
        %% Edit patient XML
        % Log patient XML
        Event(['Found patient archive ', folderList(i).name]);

        % Generate separate path and names for XML
        [path, ~, ~] = ...
            fileparts(fullfile(varargin{1}, folderList(i).name));
        
        % Open file handle to XML file
        fid = fopen(fullfile(varargin{1}, folderList(i).name), 'r');
        
        % Open write file handle to new XML file
        fid2 = fopen(fullfile(path, ...
            sprintf('Anon_%04i_patient.xml', count)), 'w');
        
        % Retrieve first line of file
        tline = fgetl(fid);
        
        % While contents exist in the line
        while ischar(tline)
            
            % Replace patient name, if found
            tline = regexprep(tline, ...
                '(<patientName [^>]+>)[^<]+(</patientName>)', ...
                ['$1', sprintf('Anon_%04i', count), '$2']);
            
            % Replace patient id, if found
            tline = regexprep(tline, ...
                '(<patientID [^>]+>)[^<]+(</patientID>)', ...
                ['$1', sprintf('%i', floor(now*1000*1000)), '$2']);
            
            % Remove patient birthdate, if found
            tline = regexprep(tline, ...
                '(<patientBirthDate [^>]+>)[^<]+(</patientBirthDate>)', ...
                '$1$2');
            
            % Write line to new XML file
            fprintf(fid2, '%s\n', tline);
            
            % Get the next line
            tline = fgetl(fid);
        end

        % Close file handles
        fclose(fid);
        fclose(fid2);
        
        % Delete original file
        delete(fullfile(varargin{1}, folderList(i).name));
        
        % Delete archive signature
        delete(fullfile(path, 'archive.sig'));
        
        %% Rename folder
        % Split subfolders into cell array
        [C, ~] = strsplit(path, '/');
        
        % Rename the last folder
        C{length(C)} = sprintf('Anon_%04i', count);
        
        % Move the patient archive folder to a new name
        movefile(path, strjoin(C, '/'));
        
        % Log new name
        Event(['Anonymized archive to ', strjoin(C, '/')]);
        
        % Increment the counter
        count = count + 1;
        
        % Clear temporary variables
        clear fid fid2 tline path C p;
    end
end

% Subtract initial count
if nargin == 2
    count = count - varargin{2};
else
    count = count - 1;
end

% Log completion
Event(sprintf(['AnonymizeDatasets processed %i patient archives in ', ...
    '%0.3f seconds'], count, toc));

% Clear temporary variables
clear count;
