# SlopesExplorer
Genration of the KML file containing mointain slopes information from the ESRI GRID data.

The apllication searches for the slopes with specified length and vertical drop within the ESRI GRID(ARC ASCII) file.
Download ESRII GRID data in ASCII format for the specified region here: http://srtm.csi.cgiar.org/SELECTION/inputCoord.asp 
Create database from the sql-script file located in the /SQLScripts folder

installer: https://drive.google.com/open?id=0B-0gJ3Dj4T_iOXpVNFZ4RjhmaDA
example of the generated kml files: https://drive.google.com/open?id=0B-0gJ3Dj4T_iS0N3VWZkSmJrMjQ

usage example: SlopesExplorer. -d 150 -a 15 -f c:\proto\srt\nj.asc -o "c:\temp\nj.kml" -l -p -s 100  -x

please feel free to contact me: igor.kanel@gmail.com
