# atlas_labeler
This tool takes in MNI coordinate files and outputs atlas labels. It was originally design for localizing electrode contacts in epilepsy patients.

Usage:
[regions,D,atlas] = mniCoord2Label('test_input.csv','AAL116')
or
[regions,D,atlas] = mniCoord2Label('test_input.csv','JHU48')
