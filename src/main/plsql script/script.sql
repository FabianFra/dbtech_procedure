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
    END TestFunktion;
  
  FUNCTION FindFahrzeugInBuchungTB(p_kennzeichen IN VARCHAR2)
    RETURN NUMBER
    IS achs VARCHAR2(5);
    BEGIN
        SELECT  m.ACHSZAHL
        into  achs
        FROM Buchung b
        INNER JOIN MAUTKATEGORIE m
        ON b.KATEGORIE_ID = m.KATEGORIE_ID
        WHERE B.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
              
        return 2;
        EXCEPTION 
            WHEN NO_DATA_FOUND then
            DBMS_OUTPUT.PUT_LINE('UNKNOWN_VEHICLE exception raised');
            raise UNKOWN_VEHICLE;
            
  
    END FindFahrzeugInBuchungTB;
    
    FUNCTION FindFahrzeugInFahrzeugTB(p_kennzeichen IN VARCHAR2)  
    RETURN NUMBER
    IS achs NUMBER;
    BEGIN 
        
        SELECT  f.ACHSEN
        into  achs
        FROM Fahrzeug f
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
    
        return achs;
    
        EXCEPTION 
            WHEN NO_DATA_FOUND then
                return FindFahrzeugInBuchungTB(p_kennzeichen);   
         
    END FindFahrzeugInFahrzeugTB;
    
    FUNCTION IsManuel(p_kennzeichen FAHRZEUG.KENNZEICHEN%Type)
    Return boolean
    IS
    county number;
    BEGIN
        SELECT count(*)
        INTO county
        FROM BUCHUNG
        WHERE Kennzeichen = p_kennzeichen AND B_ID = 1;
        
        IF county != 0 THEN
            return true;
        Else
            return false;
        END IF;      
    END IsManuel;
    
    
    FUNCTION PruefungAchszahlAV(p_achszahlFZ FAHRZEUG.ACHSEN%TYPE, p_achszahlUI FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS correctAchs boolean;
    
    BEGIN
    
    IF p_achszahlFZ <= 4 THEN
        IF p_achszahlFZ = p_achszahlUI THEN
            correctAchs := True;
        ELSE
            correctAchs := False;
        END IF;
    ELSE
        IF p_achszahlFZ >= p_achszahlUI THEN
            correctAchs := TRUE;
        ELSE
            correctAchs := FALSE;
        END IF;
    END IF;
    
    return correctAchs;
    
    END PruefungAchszahlAV;
    
    FUNCTION PruefungAchszahlMV(p_kennzeichen FAHRZEUG.KENNZEICHEN%Type, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS 
    correctAchs boolean; 
    achszahlMK varchar2(100);
    BEGIN
    
    
    
    SELECT ACHSZAHL
    INTO achszahlMK
    FROM BUCHUNG b INNER JOIN MAUTKATEGORIE ma ON b.KATEGORIE_ID = ma.KATEGORIE_ID
    WHERE Kennzeichen = p_kennzeichen AND B_ID = 1;
    
    case achszahlMK
        when '= 2' then correctAchs := P_ACHSZAHL = 2;
        when '= 3' then correctAchs := P_ACHSZAHL = 3;
        when '= 4' then correctAchs := P_ACHSZAHL = 4;
        when '>= 5' then correctAchs := P_ACHSZAHL >= 5;
    end case;
       
    return correctAchs;
    
    END PruefungAchszahlMV;
    
    FUNCTION PruefungOffeneBuchungMV(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    Return boolean
    IS 
    county number;
        
    BEGIN
    
    SELECT count(*)
    INTO county
    FROM BUCHUNG 
    WHERE KENNZEICHEN = P_KENNZEICHEN AND B_ID = 1;
    
    IF county >= 0 THEN
        return true;
    ELSE 
        return false;
    END IF;
    
    END PruefungOffeneBuchungMV;
    
    PROCEDURE BERECHNEMAUT(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE) AS 
    v_dummy integer; 
    fID  FAHRZEUG.FZ_ID%TYPE;
    achs  FAHRZEUG.ACHSEN%TYPE;
    kz FAHRZEUG.KENNZEICHEN%TYPE;
    aut BOOLEAN;
    
    
    BEGIN 
        achs := FindFahrzeugInFahrzeugTB(P_KENNZEICHEN);
        
        IF IsManuel(P_KENNZEICHEN) = TRUE Then
            
            DBMS_OUTPUT.PUT_LINE('Is in the manuel procedure');
            if PruefungAchszahlMV(P_KENNZEICHEN, P_ACHSZAHL) = TRUE THEN
                
                if PruefungOffeneBuchungMV(P_KENNZEICHEN) != TRUE THEN
                    DBMS_OUTPUT.PUT_LINE('Has no open booking');
                else
                    DBMS_OUTPUT.PUT_LINE('ALREADY_CRUISED exception raised for manuel procedure');
                    RAISE ALREADY_CRUISED;
                END IF;
                
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for manuel procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
            
            
        ELSE
        
            DBMS_OUTPUT.PUT_LINE('Is in the automatic procedure');
            
            IF PruefungAchszahlAV(achs, P_ACHSZAHL) = TRUE THEN
                DBMS_OUTPUT.PUT_LINE('Alles fit');
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for automatic procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
            
        END IF;
        
    END BERECHNEMAUT;

END maut_service;

