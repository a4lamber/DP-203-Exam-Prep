CREATE TABLE Course
(
   CourseID int,
   ExamImage varchar(1000),
   CourseName varchar(1000),
   Rating numeric(2,1)
)

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(1,'https://datastore2000.blob.core.windows.net/data/AZ-204.jpg','AZ-204 Developing Azure solutions',4.5)

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(2,'https://datastore2000.blob.core.windows.net/data/AZ-303.jpg','AZ-303 Architecting Azure solutions',4.6)

INSERT INTO Course(CourseID,ExamImage,CourseName,Rating) VALUES(3,'https://datastore2000.blob.core.windows.net/data/DP-203.jpg','DP-203 Azure Data Engineer',4.7)

SELECT * FROM Course
