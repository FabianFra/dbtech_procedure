/*Bitte achte drauf, dass die DBMS-Ausgabe aktiviert ist. (Ansicht -> DBMS-Ausgabe)*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE BODY maut_service IS
    
    /*
    Dies ist eine Beispielfunktion, in welcher du die grobe Synthax sehen kannst. Nehme das einfach als Muster für die 
    zu schreibenden Funktionen. Falls du eine neue Funktion hinzufügst oder diese veränderst musst du dieses Script erneut
    ausführen.
    */
    FUNCTION TestFunktion(p_name IN VARCHAR2)
    RETURN VARCHAR2
    IS
    BEGIN
    RETURN('WELCOME ' || p_name);
    END test123;



    PROCEDURE BERECHNEMAUT(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE) AS 
    v_dummy integer; 
    fID  FAHRZEUG.FZ_ID%TYPE;
    achs  FAHRZEUG.ACHSEN%TYPE;
    kz FAHRZEUG.KENNZEICHEN%TYPE;
    aut BOOLEAN;


    BEGIN 
    DBMS_OUTPUT.PUT_LINE(TestFunktion('Fabian')); /*So schreibst du etwas in die DBMS-Ausgabe*/
    
    
    
    SELECT f.KENNZEICHEN, f.ACHSEN
    into kz, achs
    FROM Fahrzeug f
    WHERE f.KENNZEICHEN = P_KENNZEICHEN;

    SELECT b.KENNZEICHEN into kz
    FROM BUCHUNG b
    WHERE b.KENNZEICHEN = P_KENNZEICHEN;

    IF kz IS NOT NULL  THEN
        IF achs != P_ACHSZAHL THEN
            raise INVALID_VEHICLE_DATA;
        ELSE 
        raise INVALID_VEHICLE_DATA;

    END IF;
/*
manuel
*/


    END IF;

    EXCEPTION 
    WHEN NO_DATA_FOUND then
        raise UNKOWN_VEHICLE;
    WHEN others then
        raise UNKOWN_VEHICLE;
   
        
    
            
    END BERECHNEMAUT;

END maut_service;