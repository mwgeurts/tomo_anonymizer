TomoTherapy Batch Archive Anonymizer
===========

by Mark Geurts <mark.w.geurts@gmail.com>
<br>Copyright &copy; 2014, University of Wisconsin Board of Regents

AnonymizeDatasets scans a folder for TomoTherapy&reg; patient archives. For each archive found, the patient's name and MRN are removed, the archive signature file is deleted, and the folder is renamed.  Patient names/folders will be renamed incrementally (Anon_0001, Anon_0002, etc) starting from 1 or an optionally provided integer.  Note, the original and new archive names are recorded using the `Event()` function to the file `log.txt`.  Therefore, to remove any connection of the original and anonymized archives, this file should be deleted following execution.

WARNING: THIS WILL MODIFY ALL PATIENT ARCHIVES, RENDERING THEM UNABLE TO RESTORE BACK TO A TOMOTHERAPY DATABASE.

TomoTherapy is a registered trademark of Accuray Incorporated.

## Installation

Copy the MATLAB *.m files from this repository into the MATLAB path.

## Usage and Documentation

```matlab
folder = './Archives'; % Folder containing the archives
startNum = 11; % Start numbering at 11
AnonymizeDatasets(folder, startNum);
```

## License

Released under the GNU GPL v3.0 License.  See the [LICENSE](LICENSE) file for further details.
