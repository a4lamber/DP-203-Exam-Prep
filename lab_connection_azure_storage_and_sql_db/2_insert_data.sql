

/*
ServerName.blob.core.windows.net/containerName/filename.png

现在有个bug, 你只能在不保存这个文件的情况下，run the following commands else it returns "Cannot connect to the database due to invalid OwnerUri (Parameter 'OwnerUri')"

*/

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(1,'https://udemydp203adam.blob.core.windows.net/data/az_204.png.jpg','AZ-204 Developing Azure solutions',4.5)

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(2,'https://udemydp203adam.blob.core.windows.net/data/az_303.png','AZ-303 Architecting Azure solutions',4.6)

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(3,'https://udemydp203adam.blob.core.windows.net/data/dp_203.png','DP-203 Azure Data Engineer',4.7)

