INSERT INTO server.LOCATION(ID,CODE,NAME) VALUES(2,'LOCALIZATION2','Localización secundaria');

INSERT INTO server.QUALIFICATION_SESSION (ID,LOCATION_ID,START_DATE,END_DATE) VALUES
                                                                               (1,1,'2023-11-13 11:52:21','2023-11-13 08:58:16'),
                                                                               (2,1,'2023-11-13 11:58:39','2023-11-14 09:01:34'),
                                                                               (3,1,'2023-11-13 11:58:39','2023-11-15 09:01:34'),
                                                                               (4,1,'2023-11-13 11:58:39','2023-12-16 09:01:34'),
                                                                               (5,1,'2023-11-13 11:58:39','2023-12-17 09:01:34');

INSERT INTO server.`USER` (ID, USER_NAME,`TYPE`) VALUES
                                                 (1, 'David','QUALIFIER'),
                                                 (2, 'Cristian','VIEWER');


INSERT INTO server.USER_QUALIFICATION_SESSION (USER_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (1,1),
                                                                                     (1,2),
                                                                                     (1,3),
                                                                                     (1,4),
                                                                                     (1,5);


INSERT INTO server.IMAGE_SET (ID, SET_CODE,IDENTIFICATION) VALUES
                                                           (1,'21b7cf40-29a5-4fe5-9cfa-17c199af8775','UHSJQ3'),
                                                           (2, '491ab7f2-dcfe-4be5-8f83-c41a9a84ebce','GSVQMB'),
                                                           (3, '5bb6693f-c06f-4e98-96d2-8d6585ec14c6','9ZF1TV'),
                                                           (4, '795627d9-69d6-4012-959f-83f6b1cc750e','GG8CWT'),
                                                           (5, 'a0df0168-89e3-450d-a791-f9e2ef3d5fa0','TEURMB'),
                                                           (6, 'fe26af10-c8a8-48cc-b1d3-dc56ec29bfad','BYHRFV'),
                                                           (7, 'aa0feb54-963c-45de-b760-2d9644ca90b1','AJ2RIR'),
                                                           (8, '51f15e05-52f1-43f8-b981-d777b81e2a09','DT4NWA'),
                                                           (9, 'a71a262c-6fe2-4967-800d-bb599c6075e3','IFFVM7'),
                                                           (10, 'b31e821e-0ff2-4292-ac39-ed1de92489d1','7749T6'),
                                                           (11,'507f42db-8c75-46c3-859b-457ab9df8ee8','RW674H'),
                                                           (12,'bb739fb7-b8d7-439f-a38e-a1a24ae1b6e7','RSVZ1B'),
                                                           (13,'4a7f8129-c0f7-4ebd-9c6e-18350c40f5c7','ZHBMMB'),
                                                           (14,'2677e230-029b-4c9a-9e85-d80a537e0aa2','MQ8ABZ'),
                                                           (15,'01abeef8-ef4a-4f85-a758-733d9cb248d3','7PSFVM');
INSERT INTO server.IMAGE_SET (ID, SET_CODE,IDENTIFICATION) VALUES
                                                           (16,'bfef9b09-b71a-4e2f-ac7c-e8ac6ef4e77b','UHSJQ3'),
                                                           (17,'8d9212ff-2cbc-4113-b235-d8fa4da30976','GSVQMB'),
                                                           (18,'683fe0b5-1290-4d48-88e2-0e11a1c55ea6','9ZF1TV'),
                                                           (19,'35a56233-5877-41fb-9bfd-24a074a8b53f','GG8CWT'),
                                                           (20,'744b27fc-64d9-4f9b-b34a-f677ffc1d3c9','TEURMB'),
                                                           (21,'0b991284-aa64-467d-be6c-128614452b75','BYHRFV'),
                                                           (22,'123725a4-7a97-4655-84ad-8fdcefa373b4','AJ2RIR'),
                                                           (23,'bf7fdb1f-5ccc-4d34-a499-7d4251bcfecd','DT4NWA'),
                                                           (24,'6dcffdad-4bc1-42de-b6a9-2650b47f6a80','IFFVM7'),
                                                           (25,'18636d33-2335-4cbd-b4c8-09faed660a45','7749T6'),
                                                           (26,'55e4d956-8974-4b30-952a-ea04e80f2354','RW674H'),
                                                           (27,'0e51a474-876f-458b-921a-322280ccdbc1','RSVZ1B'),
                                                           (28,'9a0bd67a-e024-4ee1-a5cc-5bb1dea97f58','ZHBMMB'),
                                                           (29,'fb761bd1-ac76-4e77-9e81-0ba115a65862','MQ8ABZ'),
                                                           (30,'3a50b1bd-8cba-40f1-ae6d-748eb99e0971','7PSFVM');



INSERT INTO server.IMAGE_SET (ID, SET_CODE,IDENTIFICATION) VALUES
                                                               (31,'5de831dc-8be4-11ee-b9d1-0242ac120002','UHSJQ3'),
                                                               (32,'1431e85c-8c71-11ee-b9d1-0242ac120002','GSVQMB'),
                                                               (33,'18d7e456-8c71-11ee-b9d1-0242ac120002','9ZF1TV'),
                                                               (34,'1b6644c4-8c71-11ee-b9d1-0242ac120002','GG8CWT'),
                                                               (35,'20e3e370-8c71-11ee-b9d1-0242ac120002','TEURMB'),
                                                               (36,'25e42a10-8c71-11ee-b9d1-0242ac120002','BYHRFV'),
                                                               (37,'286f4170-8c71-11ee-b9d1-0242ac120002','AJ2RIR'),
                                                               (38,'2b651a26-8c71-11ee-b9d1-0242ac120002','DT4NWA'),
                                                               (39,'2dfe0630-8c71-11ee-b9d1-0242ac120002','IFFVM7'),
                                                               (40,'30710d72-8c71-11ee-b9d1-0242ac120002','7749T6'),
                                                               (41,'333d59d4-8c71-11ee-b9d1-0242ac120002','RW674H'),
                                                               (42,'35b1ab5c-8c71-11ee-b9d1-0242ac120002','RSVZ1B'),
                                                               (43,'380d54f0-8c71-11ee-b9d1-0242ac120002','ZHBMMB'),
                                                               (44,'3ab53664-8c71-11ee-b9d1-0242ac120002','MQ8ABZ'),
                                                               (45,'3d09f95e-8c71-11ee-b9d1-0242ac120002','7PSFVM');

INSERT INTO server.IMAGE_SET (ID, SET_CODE,IDENTIFICATION) VALUES
                                                               (46,'4084717c-8c71-11ee-b9d1-0242ac120002','UHSJQ3'),
                                                               (47,'434abf6a-8c71-11ee-b9d1-0242ac120002','GSVQMB'),
                                                               (48,'45b95892-8c71-11ee-b9d1-0242ac120002','9ZF1TV'),
                                                               (49,'48bb3b82-8c71-11ee-b9d1-0242ac120002','GG8CWT'),
                                                               (50,'4c249552-8c71-11ee-b9d1-0242ac120002','TEURMB'),
                                                               (51,'4ea12f5c-8c71-11ee-b9d1-0242ac120002','BYHRFV'),
                                                               (52,'5217c7ea-8c71-11ee-b9d1-0242ac120002','AJ2RIR'),
                                                               (53,'54f87608-8c71-11ee-b9d1-0242ac120002','DT4NWA'),
                                                               (54,'579b4728-8c71-11ee-b9d1-0242ac120002','IFFVM7'),
                                                               (55,'5a5113c6-8c71-11ee-b9d1-0242ac120002','7749T6'),
                                                               (56,'5ccb3ed8-8c71-11ee-b9d1-0242ac120002','RW674H'),
                                                               (57,'5f3d6722-8c71-11ee-b9d1-0242ac120002','RSVZ1B'),
                                                               (58,'61fbb144-8c71-11ee-b9d1-0242ac120002','ZHBMMB'),
                                                               (59,'65017bf8-8c71-11ee-b9d1-0242ac120002','MQ8ABZ'),
                                                               (60,'677aa396-8c71-11ee-b9d1-0242ac120002','7PSFVM');

INSERT INTO server.IMAGE_SET (ID, SET_CODE,IDENTIFICATION) VALUES
                                                               (61,'6bc366d6-8c71-11ee-b9d1-0242ac120002','UHSJQ3'),
                                                               (62,'6e5468aa-8c71-11ee-b9d1-0242ac120002','GSVQMB'),
                                                               (63,'70bdbb0a-8c71-11ee-b9d1-0242ac120002','9ZF1TV'),
                                                               (64,'736b6f32-8c71-11ee-b9d1-0242ac120002','GG8CWT'),
                                                               (65,'761689f6-8c71-11ee-b9d1-0242ac120002','TEURMB'),
                                                               (66,'787140a6-8c71-11ee-b9d1-0242ac120002','BYHRFV'),
                                                               (67,'7b237c92-8c71-11ee-b9d1-0242ac120002','AJ2RIR'),
                                                               (68,'7e054576-8c71-11ee-b9d1-0242ac120002','DT4NWA'),
                                                               (69,'806b4c3e-8c71-11ee-b9d1-0242ac120002','IFFVM7'),
                                                               (70,'832f0f8c-8c71-11ee-b9d1-0242ac120002','7749T6'),
                                                               (71,'85827b70-8c71-11ee-b9d1-0242ac120002','RW674H'),
                                                               (72,'87f7a628-8c71-11ee-b9d1-0242ac120002','RSVZ1B'),
                                                               (73,'8a415582-8c71-11ee-b9d1-0242ac120002','ZHBMMB'),
                                                               (74,'8d9dc97c-8c71-11ee-b9d1-0242ac120002','MQ8ABZ'),
                                                               (75,'90395854-8c71-11ee-b9d1-0242ac120002','7PSFVM');


INSERT INTO server.IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                               (1,1),
                                                                                               (2,1),
                                                                                               (3,1),
                                                                                               (4,1),
                                                                                               (5,1),
                                                                                               (6,1),
                                                                                               (7,1),
                                                                                               (8,1),
                                                                                               (9,1),
                                                                                               (10,1),
                                                                                               (11,1),
                                                                                               (12,1),
                                                                                               (13,1),
                                                                                               (14,1),
                                                                                               (15,1);
INSERT INTO server.IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                               (16,2),
                                                                                               (17,2),
                                                                                               (18,2),
                                                                                               (19,2),
                                                                                               (20,2),
                                                                                               (21,2),
                                                                                               (22,2),
                                                                                               (23,2),
                                                                                               (24,2),
                                                                                               (25,2),
                                                                                               (26,2),
                                                                                               (27,2),
                                                                                               (28,2),
                                                                                               (29,2),
                                                                                               (30,2);

INSERT INTO server.IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                               (31,3),
                                                                                               (32,3),
                                                                                               (33,3),
                                                                                               (34,3),
                                                                                               (35,3),
                                                                                               (36,3),
                                                                                               (37,3),
                                                                                               (38,3),
                                                                                               (39,3),
                                                                                               (40,3),
                                                                                               (41,3),
                                                                                               (42,3),
                                                                                               (43,3),
                                                                                               (44,3),
                                                                                               (45,3);

INSERT INTO server.IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                               (46,4),
                                                                                               (47,4),
                                                                                               (48,4),
                                                                                               (49,4),
                                                                                               (50,4),
                                                                                               (51,4),
                                                                                               (52,4),
                                                                                               (53,4),
                                                                                               (54,4),
                                                                                               (55,4),
                                                                                               (56,4),
                                                                                               (57,4),
                                                                                               (58,4),
                                                                                               (59,4),
                                                                                               (60,4);

INSERT INTO server.IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID,QUALIFICATION_SESSION_ID) VALUES
                                                                                               (61,5),
                                                                                               (62,5),
                                                                                               (63,5),
                                                                                               (64,5),
                                                                                               (65,5),
                                                                                               (66,5),
                                                                                               (67,5),
                                                                                               (68,5),
                                                                                               (69,5),
                                                                                               (70,5),
                                                                                               (71,5),
                                                                                               (72,5),
                                                                                               (73,5),
                                                                                               (74,5),
                                                                                               (75,5);




INSERT INTO server.IMAGE (ID, IMAGE_SET_ID) VALUES
                                                            (1, 1),
                                                            (2, 2),
                                                            (3, 3),
                                                            (4, 4),
                                                            (5, 5),
                                                            (6, 6),
                                                            (7, 7),
                                                            (8, 8),
                                                            (9, 9),
                                                            (10,10),
                                                            (11,11),
                                                            (12,12),
                                                            (13,13),
                                                            (14,14),
                                                            (15,15);
INSERT INTO server.IMAGE (ID, IMAGE_SET_ID) VALUES
                                                            (16,16),
                                                            (17,17),
                                                            (18,18),
                                                            (19,19),
                                                            (20,20),
                                                            (21,21),
                                                            (22,22),
                                                            (23,23),
                                                            (24,24),
                                                            (25,25),
                                                            (26,26),
                                                            (27,27),
                                                            (28,28),
                                                            (29,29),
                                                            (30,30);

INSERT INTO server.IMAGE (ID, IMAGE_SET_ID) VALUES
                                                (31, 31),
                                                (32, 32),
                                                (33, 33),
                                                (34, 34),
                                                (35, 35),
                                                (36, 36),
                                                (37, 37),
                                                (38, 38),
                                                (39, 39),
                                                (40,40),
                                                (41,41),
                                                (42,42),
                                                (43,43),
                                                (44,44),
                                                (45,45);
INSERT INTO server.IMAGE (ID, IMAGE_SET_ID) VALUES
                                                (46,46),
                                                (47,47),
                                                (48,48),
                                                (49,49),
                                                (50,50),
                                                (51,51),
                                                (52,52),
                                                (53,53),
                                                (54,54),
                                                (55,55),
                                                (56,56),
                                                (57,57),
                                                (58,58),
                                                (59,59),
                                                (60,60);

INSERT INTO server.IMAGE (ID, IMAGE_SET_ID) VALUES
                                                (61, 61),
                                                (62, 62),
                                                (63, 63),
                                                (64, 64),
                                                (65, 65),
                                                (66, 66),
                                                (67, 67),
                                                (68, 68),
                                                (69, 69),
                                                (70,70),
                                                (71,71),
                                                (72,72),
                                                (73,73),
                                                (74,74),
                                                (75,75);


INSERT INTO server.PREDICTED_SCORE (IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (1,3.0000,1),
                                                                                     (2,3.0000,1),
                                                                                     (3,3.0000,1),
                                                                                     (4,3.5000,1),
                                                                                     (5,3.2500,1),
                                                                                     (6,3.5000,1),
                                                                                     (7,2.5000,1),
                                                                                     (8,2.5000,1),
                                                                                     (9,2.5000,1),
                                                                                     (10,2.5000,1),
                                                                                     (11,3.2500,1),
                                                                                     (12,3.2500,1),
                                                                                     (13,3.2500,1),
                                                                                     (14,2.7500,1),
                                                                                     (15,2.5000,1);
INSERT INTO server.PREDICTED_SCORE (IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (16,3.1000,2),
                                                                                     (17,2.9000,2),
                                                                                     (18,3.2000,2),
                                                                                     (19,3.3000,2),
                                                                                     (20,3.6500,2),
                                                                                     (21,3.7000,2),
                                                                                     (22,2.2000,2),
                                                                                     (23,2.3000,2),
                                                                                     (24,2.4000,2),
                                                                                     (25,2.1000,2),
                                                                                     (26,3.8500,2),
                                                                                     (27,3.3500,2),
                                                                                     (28,3.1500,2),
                                                                                     (29,2.4500,2),
                                                                                     (30,2.5500,2);


INSERT INTO server.PREDICTED_SCORE (IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (31,3.2000,3),
                                                                                     (32,3.0000,3),
                                                                                     (33,3.2000,3),
                                                                                     (34,3.3000,3),
                                                                                     (35,4.0000,3),
                                                                                     (36,3.8000,3),
                                                                                     (37,2.1000,3),
                                                                                     (38,2.4000,3),
                                                                                     (39,2.5000,3),
                                                                                     (40,2.2000,3),
                                                                                     (41,4.0000,3),
                                                                                     (42,3.4500,3),
                                                                                     (43,3.0500,3),
                                                                                     (44,2.7500,3),
                                                                                     (45,2.5000,3);
INSERT INTO server.PREDICTED_SCORE (IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (46,3.3000,4),
                                                                                     (47,3.1000,4),
                                                                                     (48,3.1000,4),
                                                                                     (49,3.1000,4),
                                                                                     (50,3.8000,4),
                                                                                     (51,3.9000,4),
                                                                                     (52,2.0000,4),
                                                                                     (53,2.4500,4),
                                                                                     (54,2.4000,4),
                                                                                     (55,2.3000,4),
                                                                                     (56,3.9000,4),
                                                                                     (57,3.4500,4),
                                                                                     (58,2.9500,4),
                                                                                     (59,2.8500,4),
                                                                                     (60,2.5500,4);


INSERT INTO server.PREDICTED_SCORE (IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES
                                                                                     (61,3.1000,5),
                                                                                     (62,3.0500,5),
                                                                                     (63,3.0000,5),
                                                                                     (64,3.3000,5),
                                                                                     (65,3.3000,5),
                                                                                     (66,4.0000,5),
                                                                                     (67,1.9000,5),
                                                                                     (68,2.5000,5),
                                                                                     (69,2.5000,5),
                                                                                     (70,2.4000,5),
                                                                                     (71,3.8000,5),
                                                                                     (72,3.5500,5),
                                                                                     (73,3.0500,5),
                                                                                     (74,3.0000,5),
                                                                                     (75,2.5500,5);

