DELETE FROM Blog_Comments;
DELETE FROM Blog_Article_Tags;
DELETE FROM Blog_Article_Categories;
DELETE FROM Blog_Articles;
DELETE FROM Blog_Tags;
DELETE FROM Blog_Categories;
DELETE FROM Blog_Users;
COMMIT;

-- Autores y pensadores usados como datos de prueba.
MERGE INTO Blog_Users t USING (SELECT 'Julio Cortázar' Full_Name, 'julio.cortazar@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);
MERGE INTO Blog_Users t USING (SELECT 'Søren Kierkegaard' Full_Name, 'soren.kierkegaard@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);
MERGE INTO Blog_Users t USING (SELECT 'Ursula K. Le Guin' Full_Name, 'ursula.leguin@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);
MERGE INTO Blog_Users t USING (SELECT 'Jorge Luis Borges' Full_Name, 'jorge.borges@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);
MERGE INTO Blog_Users t USING (SELECT 'Simone de Beauvoir' Full_Name, 'simone.beauvoir@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);
MERGE INTO Blog_Users t USING (SELECT 'Clarice Lispector' Full_Name, 'clarice.lispector@blog.local' Email FROM dual) s ON (t.Email=s.Email)
WHEN NOT MATCHED THEN INSERT (Full_Name, Email) VALUES (s.Full_Name, s.Email);

MERGE INTO Blog_Categories t USING (SELECT 'Literatura' Name, 'literatura' Slug FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Categories t USING (SELECT 'Filosofía' Name, 'filosofia' Slug FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Categories t USING (SELECT 'Cuento' Name, 'cuento' Slug FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Categories t USING (SELECT 'Ensayo' Name, 'ensayo' Slug FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Categories t USING (SELECT 'Existencialismo' Name, 'existencialismo' Slug FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);

MERGE INTO Blog_Tags t USING (SELECT 'realismo-magico' Slug, 'Realismo mágico' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Tags t USING (SELECT 'laberintos' Slug, 'Laberintos' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Tags t USING (SELECT 'libertad' Slug, 'Libertad' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Tags t USING (SELECT 'identidad' Slug, 'Identidad' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Tags t USING (SELECT 'fantasia' Slug, 'Fantasía' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);
MERGE INTO Blog_Tags t USING (SELECT 'tiempo' Slug, 'Tiempo' Name FROM dual) s ON (t.Slug=s.Slug)
WHEN NOT MATCHED THEN INSERT (Name, Slug) VALUES (s.Name, s.Slug);

MERGE INTO Blog_Articles t USING (
    SELECT User_Id Author_Id, 'La ciudad que cambia al ser narrada' Title,
      q'[Una ciudad no es solo sus calles: también es la versión que cada caminante recuerda. Al escribirla, el narrador descubre que la esquina de ayer ya pertenece a otro mapa.]' Body
    FROM Blog_Users WHERE Email='julio.cortazar@blog.local'
) s ON (t.Title=s.Title)
-- La fecha de este artículo se elige al azar entre 2024 y 2026.
WHEN NOT MATCHED THEN INSERT (Author_Id, Title, Body, Published_At) VALUES (s.Author_Id, s.Title, s.Body, CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP));

MERGE INTO Blog_Articles t USING (
    SELECT User_Id Author_Id, 'Elegir incluso cuando nadie observa' Title,
      q'[La elección cotidiana no necesita testigos para tener peso. La responsabilidad aparece precisamente cuando dejamos de buscar una respuesta cómoda fuera de nosotros.]' Body
    FROM Blog_Users WHERE Email='soren.kierkegaard@blog.local'
) s ON (t.Title=s.Title)
WHEN NOT MATCHED THEN INSERT (Author_Id, Title, Body, Published_At) VALUES (s.Author_Id, s.Title, s.Body, CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP));

MERGE INTO Blog_Articles t USING (
    SELECT User_Id Author_Id, 'Imaginación como herramienta de futuro' Title,
      q'[La imaginación no huye del mundo: ensaya maneras distintas de habitarlo. Una historia puede abrir preguntas que un manual todavía no sabe formular.]' Body
    FROM Blog_Users WHERE Email='ursula.leguin@blog.local'
) s ON (t.Title=s.Title)
WHEN NOT MATCHED THEN INSERT (Author_Id, Title, Body, Published_At) VALUES (s.Author_Id, s.Title, s.Body, CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP));

MERGE INTO Blog_Articles t USING (
    SELECT User_Id Author_Id, 'El archivo y sus infinitas posibilidades' Title,
      q'[Toda biblioteca promete orden, pero cada lector inventa un recorrido. Entre dos estantes puede aparecer una pregunta que transforma el sentido del catálogo entero.]' Body
    FROM Blog_Users WHERE Email='jorge.borges@blog.local'
) s ON (t.Title=s.Title)
WHEN NOT MATCHED THEN INSERT (Author_Id, Title, Body, Published_At) VALUES (s.Author_Id, s.Title, s.Body, CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP));

MERGE INTO Blog_Articles t USING (
    SELECT User_Id Author_Id, 'Escribir desde la propia experiencia' Title,
      q'[La experiencia personal no es una habitación cerrada. Cuando se cuenta con honestidad, encuentra hilos que la unen con las preguntas de otras personas.]' Body
    FROM Blog_Users WHERE Email='simone.beauvoir@blog.local'
) s ON (t.Title=s.Title)
WHEN NOT MATCHED THEN INSERT (Author_Id, Title, Body, Published_At) VALUES (s.Author_Id, s.Title, s.Body, CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP));

MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='La ciudad que cambia al ser narrada' AND c.Slug='literatura') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='La ciudad que cambia al ser narrada' AND c.Slug='cuento') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='Elegir incluso cuando nadie observa' AND c.Slug='filosofia') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='Elegir incluso cuando nadie observa' AND c.Slug='existencialismo') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='Imaginación como herramienta de futuro' AND c.Slug='literatura') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='El archivo y sus infinitas posibilidades' AND c.Slug='ensayo') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);
MERGE INTO Blog_Article_Categories t USING (SELECT a.Article_Id,c.Category_Id FROM Blog_Articles a CROSS JOIN Blog_Categories c WHERE a.Title='Escribir desde la propia experiencia' AND c.Slug='ensayo') s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Category_Id) VALUES (s.Article_Id,s.Category_Id);

MERGE INTO Blog_Article_Tags t USING (SELECT a.Article_Id,g.Tag_Id FROM Blog_Articles a CROSS JOIN Blog_Tags g WHERE a.Title='La ciudad que cambia al ser narrada' AND g.Slug='realismo-magico') s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Tag_Id) VALUES (s.Article_Id,s.Tag_Id);
MERGE INTO Blog_Article_Tags t USING (SELECT a.Article_Id,g.Tag_Id FROM Blog_Articles a CROSS JOIN Blog_Tags g WHERE a.Title='Elegir incluso cuando nadie observa' AND g.Slug='libertad') s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Tag_Id) VALUES (s.Article_Id,s.Tag_Id);
MERGE INTO Blog_Article_Tags t USING (SELECT a.Article_Id,g.Tag_Id FROM Blog_Articles a CROSS JOIN Blog_Tags g WHERE a.Title='Imaginación como herramienta de futuro' AND g.Slug='fantasia') s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Tag_Id) VALUES (s.Article_Id,s.Tag_Id);
MERGE INTO Blog_Article_Tags t USING (SELECT a.Article_Id,g.Tag_Id FROM Blog_Articles a CROSS JOIN Blog_Tags g WHERE a.Title='El archivo y sus infinitas posibilidades' AND g.Slug='laberintos') s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Tag_Id) VALUES (s.Article_Id,s.Tag_Id);
MERGE INTO Blog_Article_Tags t USING (SELECT a.Article_Id,g.Tag_Id FROM Blog_Articles a CROSS JOIN Blog_Tags g WHERE a.Title='Escribir desde la propia experiencia' AND g.Slug='identidad') s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id) WHEN NOT MATCHED THEN INSERT (Article_Id,Tag_Id) VALUES (s.Article_Id,s.Tag_Id);

INSERT INTO Blog_Comments (Article_Id, User_Id, Body)
SELECT a.Article_Id,u.User_Id,'La idea de que el relato transforma el espacio resulta muy sugerente.' FROM Blog_Articles a CROSS JOIN Blog_Users u
WHERE a.Title='La ciudad que cambia al ser narrada' AND u.Email='jorge.borges@blog.local'
AND NOT EXISTS (SELECT 1 FROM Blog_Comments c WHERE c.Article_Id=a.Article_Id AND c.User_Id=u.User_Id AND c.Body='La idea de que el relato transforma el espacio resulta muy sugerente.');
INSERT INTO Blog_Comments (Article_Id, User_Id, Body)
SELECT a.Article_Id,u.User_Id,'Una reflexión clara sobre la responsabilidad de decidir.' FROM Blog_Articles a CROSS JOIN Blog_Users u
WHERE a.Title='Elegir incluso cuando nadie observa' AND u.Email='simone.beauvoir@blog.local'
AND NOT EXISTS (SELECT 1 FROM Blog_Comments c WHERE c.Article_Id=a.Article_Id AND c.User_Id=u.User_Id AND c.Body='Una reflexión clara sobre la responsabilidad de decidir.');
INSERT INTO Blog_Comments (Article_Id, User_Id, Body)
SELECT a.Article_Id,u.User_Id,'Las historias son una forma poderosa de explorar alternativas.' FROM Blog_Articles a CROSS JOIN Blog_Users u
WHERE a.Title='Imaginación como herramienta de futuro' AND u.Email='clarice.lispector@blog.local'
AND NOT EXISTS (SELECT 1 FROM Blog_Comments c WHERE c.Article_Id=a.Article_Id AND c.User_Id=u.User_Id AND c.Body='Las historias son una forma poderosa de explorar alternativas.');

DECLARE
    TYPE Writer_List IS TABLE OF VARCHAR2(300);
    Writers Writer_List := Writer_List(
        'Franz Kafka|franz.kafka@blog.local',
        'Virginia Woolf|virginia.woolf@blog.local',
        'Albert Camus|albert.camus@blog.local',
        'Hannah Arendt|hannah.arendt@blog.local',
        'Octavio Paz|octavio.paz@blog.local',
        'Gabriel García Márquez|gabriel.marquez@blog.local',
        'Toni Morrison|toni.morrison@blog.local',
        'Italo Calvino|italo.calvino@blog.local',
        'Mary Shelley|mary.shelley@blog.local',
        'Emily Dickinson|emily.dickinson@blog.local',
        'James Baldwin|james.baldwin@blog.local',
        'George Orwell|george.orwell@blog.local',
        'Isabel Allende|isabel.allende@blog.local',
        'Fernando Pessoa|fernando.pessoa@blog.local',
        'Chinua Achebe|chinua.achebe@blog.local',
        'Marguerite Yourcenar|marguerite.yourcenar@blog.local',
        'José Saramago|jose.saramago@blog.local',
        'Susan Sontag|susan.sontag@blog.local',
        'Wislawa Szymborska|wislawa.szymborska@blog.local',
        'Naguib Mahfouz|naguib.mahfouz@blog.local',
        'Milan Kundera|milan.kundera@blog.local',
        'Zora Neale Hurston|zora.hurston@blog.local',
        'Rainer Maria Rilke|rainer.rilke@blog.local',
        'Umberto Eco|umberto.eco@blog.local'
    );
    Separator PLS_INTEGER;
BEGIN
    FOR I IN 1 .. Writers.COUNT LOOP
        Separator := INSTR(Writers(I), '|');
        BEGIN
            INSERT INTO Blog_Users (Full_Name, Email)
            VALUES (SUBSTR(Writers(I), 1, Separator - 1), SUBSTR(Writers(I), Separator + 1));
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END LOOP;
END;
/

DECLARE
    TYPE Item_List IS TABLE OF VARCHAR2(200);
    Categories Item_List := Item_List(
        'Poesía|poesia', 'Narrativa|narrativa', 'Ciencia ficción|ciencia-ficcion',
        'Memoria|memoria', 'Sociedad|sociedad'
    );
    Tags Item_List := Item_List(
        'Soledad|soledad', 'Memoria|memoria', 'Viaje|viaje', 'Lenguaje|lenguaje',
        'Ética|etica', 'Utopía|utopia', 'Historia|historia', 'Poesía|poesia',
        'Ciudad|ciudad', 'Naturaleza|naturaleza', 'Lectura|lectura', 'Sueños|suenos'
    );
    Separator PLS_INTEGER;
BEGIN
    FOR I IN 1 .. Categories.COUNT LOOP
        Separator := INSTR(Categories(I), '|');
        BEGIN INSERT INTO Blog_Categories (Name, Slug) VALUES (SUBSTR(Categories(I),1,Separator-1),SUBSTR(Categories(I),Separator+1));
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;
    END LOOP;
    FOR I IN 1 .. Tags.COUNT LOOP
        Separator := INSTR(Tags(I), '|');
        BEGIN INSERT INTO Blog_Tags (Name, Slug) VALUES (SUBSTR(Tags(I),1,Separator-1),SUBSTR(Tags(I),Separator+1));
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;
    END LOOP;
END;
/

INSERT INTO Blog_Articles (Author_Id, Title, Body, Published_At)
SELECT u.User_Id,
       'Cuaderno de lectura: ' || u.Full_Name,
       'Texto original de demostración. ' || u.Full_Name || ' propone una reflexión sobre la lectura, la memoria y la conversación entre ideas.',
       CAST(DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1096)) AS TIMESTAMP)
FROM Blog_Users u
WHERE NOT EXISTS (SELECT 1 FROM Blog_Articles a WHERE a.Author_Id = u.User_Id);

MERGE INTO Blog_Article_Categories t
USING (
    SELECT a.Article_Id, c.Category_Id
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT Category_Id, ROW_NUMBER() OVER (ORDER BY Category_Id) Row_Num FROM Blog_Categories) c
      ON c.Row_Num = MOD(a.Row_Num - 1, (SELECT COUNT(*) FROM Blog_Categories)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id)
WHEN NOT MATCHED THEN INSERT (Article_Id, Category_Id) VALUES (s.Article_Id, s.Category_Id);

MERGE INTO Blog_Article_Categories t
USING (
    SELECT a.Article_Id, c.Category_Id
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT Category_Id, ROW_NUMBER() OVER (ORDER BY Category_Id) Row_Num FROM Blog_Categories) c
      ON c.Row_Num = MOD(a.Row_Num + 2, (SELECT COUNT(*) FROM Blog_Categories)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.Category_Id=s.Category_Id)
WHEN NOT MATCHED THEN INSERT (Article_Id, Category_Id) VALUES (s.Article_Id, s.Category_Id);

MERGE INTO Blog_Article_Tags t
USING (
    SELECT a.Article_Id, g.Tag_Id
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT Tag_Id, ROW_NUMBER() OVER (ORDER BY Tag_Id) Row_Num FROM Blog_Tags) g
      ON g.Row_Num = MOD(a.Row_Num - 1, (SELECT COUNT(*) FROM Blog_Tags)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id)
WHEN NOT MATCHED THEN INSERT (Article_Id, Tag_Id) VALUES (s.Article_Id, s.Tag_Id);

MERGE INTO Blog_Article_Tags t
USING (
    SELECT a.Article_Id, g.Tag_Id
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT Tag_Id, ROW_NUMBER() OVER (ORDER BY Tag_Id) Row_Num FROM Blog_Tags) g
      ON g.Row_Num = MOD(a.Row_Num + 4, (SELECT COUNT(*) FROM Blog_Tags)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.Tag_Id=s.Tag_Id)
WHEN NOT MATCHED THEN INSERT (Article_Id, Tag_Id) VALUES (s.Article_Id, s.Tag_Id);

MERGE INTO Blog_Comments t
USING (
    SELECT a.Article_Id, u.User_Id,
           'Comentario de lectura: este artículo abre una conversación interesante.' Body
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT User_Id, ROW_NUMBER() OVER (ORDER BY User_Id) Row_Num FROM Blog_Users) u
      ON u.Row_Num = MOD(a.Row_Num, (SELECT COUNT(*) FROM Blog_Users)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.User_Id=s.User_Id AND t.Body=s.Body)
WHEN NOT MATCHED THEN INSERT (Article_Id, User_Id, Body) VALUES (s.Article_Id, s.User_Id, s.Body);

MERGE INTO Blog_Comments t
USING (
    SELECT a.Article_Id, u.User_Id,
           'Me parece valioso relacionar esta idea con otras lecturas del blog.' Body
    FROM (SELECT Article_Id, ROW_NUMBER() OVER (ORDER BY Article_Id) Row_Num FROM Blog_Articles) a
    JOIN (SELECT User_Id, ROW_NUMBER() OVER (ORDER BY User_Id) Row_Num FROM Blog_Users) u
      ON u.Row_Num = MOD(a.Row_Num + 6, (SELECT COUNT(*) FROM Blog_Users)) + 1
) s ON (t.Article_Id=s.Article_Id AND t.User_Id=s.User_Id AND t.Body=s.Body)
WHEN NOT MATCHED THEN INSERT (Article_Id, User_Id, Body) VALUES (s.Article_Id, s.User_Id, s.Body);

COMMIT;
