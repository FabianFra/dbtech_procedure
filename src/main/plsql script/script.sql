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
    
    --
    --
    --
    FUNCTION parseAchsZahl(P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)
    RETURN  MAUTKATEGORIE.achszahl%TYPE
    IS 
     r_achsen MAUTKATEGORIE.achszahl%TYPE;
    BEGIN
         case P_ACHSZAHL
        when 4 then
        r_achsen := '= 4';
        when 5 then
        r_achsen := '>= 5';
        
        end case;
        
        return r_achsen;
    END parseAchsZahl;
    
    FUNCTION GetMautKategorie(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE,P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.KATEGORIE_ID%TYPE
   
    IS
    r_kat MAUTKATEGORIE.KATEGORIE_ID%TYPE;
    t_achsen MAUTKATEGORIE.achszahl%TYPE;
    
    BEGIN
      t_achsen:= parseAchsZahl(P_ACHSZAHL);
         SELECT mk.KATEGORIE_ID
        INTO r_kat
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND mk.ACHSZAHL =t_achsen;
        return r_kat;
    
    END  GetMautKategorie;
    
    function GetMautsatzJeKm(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE,P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE
   
    IS
    MautSatzJeKM MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
    t_achsen MAUTKATEGORIE.achszahl%TYPE;
    
    BEGIN
       t_achsen:= parseAchsZahl(P_ACHSZAHL);
    
        
        DBMS_OUTPUT.PUT_LINE(t_achsen);
        DBMS_OUTPUT.PUT_LINE('START GetMautsatzJeKm');
        SELECT mk.MAUTSATZ_JE_KM
        INTO  MautSatzJeKM
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND mk.ACHSZAHL =t_achsen;
        
        return MautSatzJeKM;
        
        EXCEPTION 
         WHEN NO_DATA_FOUND then
            DBMS_OUTPUT.PUT_LINE('err ----');
        /*WHEN OTHERS then
            DBMS_OUTPUT.PUT_LINE('err 2');*/
        
    END GetMautsatzJeKm;
    
      FUNCTION GetFzgID(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    RETURN  FAHRZEUGGERAT.FZG_ID%TYPE  IS
     fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
     BEGIN
     
        SELECT  fg.fzg_id
        into fgID
        FROM FAHRZEUG f INNER JOIN FAHRZEUGGERAT fg
        ON f.fz_id  = fg.fz_ID
        WHERE f.KENNZEICHEN  = P_KENNZEICHEN;
    
        return fgId;
        
     EXCEPTION
        WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No data found');
     END GetFzgID;
    
   FUNCTION GetAbschnittLaenge(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE)
    Return MAUTABSCHNITT.LAENGE%TYPE IS
    laenge MAUTABSCHNITT.LAENGE%TYPE;
    
    BEGIN
      DBMS_OUTPUT.PUT_LINE('123test');
    SELECT LAENGE
    INTO laenge
    FROM MAUTABSCHNITT
    WHERE ABSCHNITTS_ID = P_MAUTABSCHNITT;
    
    return laenge;
    
    END GetAbschnittLaenge;
    
  
    
    PROCEDURE BerechneKostenFuerAutomatischesVerfahren(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE )
    AS
    kosten MAUTERHEBUNG.KOSTEN%TYPE;
   
    mautsatzJeKm MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
    laenge MAUTABSCHNITT.LAENGE%TYPE ;
    fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
    katID  MautKategorie.KATEGORIE_ID%TYPE;
    BEGIN 
    mautsatzJeKm  := GetMautsatzJeKm(P_KENNZEICHEN,P_MAUTABSCHNITT,P_ACHSZAHL);
    laenge := GetAbschnittLaenge(P_MAUTABSCHNITT);
    fgId := GetFzgID(P_KENNZEICHEN);
     DBMS_OUTPUT.PUT_LINE(fgID);
    katID := GetMautKategorie(P_KENNZEICHEN,P_MAUTABSCHNITT,P_ACHSZAHL);
     DBMS_OUTPUT.PUT_LINE(katID);
       /*DBMS_OUTPUT.PUT_LINE(mautsatzJeKm);
          DBMS_OUTPUT.PUT_LINE(laenge);*/
        kosten := ((laenge / 1000) * mautsatzJeKm) / 100;
          DBMS_OUTPUT.PUT_LINE(kosten);
        INSERT INTO MAUTERHEBUNG  (MAUT_ID,ABSCHNITTS_ID,FZG_ID,KATEGORIE_ID,BEFAHRUNGSDATUM,KOSTEN)
        VALUES(1018,P_MAUTABSCHNITT,fgID,katID,CURRENT_TIMESTAMP,kosten);
    
    END BerechneKostenFuerAutomatischesVerfahren;
    
  
    
    
  
    PROCEDURE BerechneKostenFuerManuellesVerfahren(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE,  P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    AS 
    kat  NUMBER;
    buchungID  NUMBER;
    b_ID NUMBER;
    BEGIN
         case P_ACHSZAHL
            when 4 then
                kat:=15;
                DBMS_OUTPUT.PUT_LINE('1');
                SELECT b.BUCHUNG_ID, b.B_ID 
                into buchungID, b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = kat AND b.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
                
            when 3 then 
                kat:=14;
                DBMS_OUTPUT.PUT_LINE('2');
                SELECT b.BUCHUNG_ID, b.B_ID
                into buchungID, b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = kat AND b.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
            else
                DBMS_OUTPUT.PUT_LINE('3');
                SELECT BUCHUNG_ID, B_ID
                into buchungID, b_ID
                FROM BUCHUNG 
                WHERE KENNZEICHEN = P_KENNZEICHEN AND ABSCHNITTS_ID = P_MAUTABSCHNITT;
        end case;
    
        if b_ID != 1 then
            DBMS_OUTPUT.PUT_LINE('4');
            raise ALREADY_CRUISED;
            
        else
            DBMS_OUTPUT.PUT_LINE(buchungID);
            UPDATE BUCHUNG SET b_id = 3, BEFAHRUNGSDATUM = CURRENT_TIMESTAMP WHERE buchung_id = buchungID AND ROWNUM = 1;
        END IF;
        
        EXCEPTION
        WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No data found');
              
    END BerechneKostenFuerManuellesVerfahren;
    
    
    
    
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
                DBMS_OUTPUT.PUT_LINE('ACHZAHL is correct');   
                BerechneKostenFuerManuellesVerfahren(P_MAUTABSCHNITT, P_ACHSZAHL, P_KENNZEICHEN);
                
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for manuel procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
            
            
        ELSE
        
            DBMS_OUTPUT.PUT_LINE('Is in the automatic procedure');
            
            IF PruefungAchszahlAV(achs, P_ACHSZAHL) = TRUE THEN
                DBMS_OUTPUT.PUT_LINE('ACHZAHL is correct');            
                BerechneKostenFuerAutomatischesVerfahren(P_MAUTABSCHNITT, P_KENNZEICHEN, P_ACHSZAHL);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for automatic procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
            
        END IF;
        
    END BERECHNEMAUT;

END maut_service;

