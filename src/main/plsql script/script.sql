/*Bitte achte drauf, dass die DBMS-Ausgabe aktiviert ist. (Ansicht -> DBMS-Ausgabe)*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE BODY maut_service IS
 
  
  FUNCTION FindFahrzeugInBuchungTB(p_kennzeichen IN VARCHAR2)
    RETURN NUMBER
    IS v_achsvar VARCHAR2(5);
    v_achs NUMBER;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('FindFahrzeugInBuchungTB Start');
        SELECT  m.ACHSZAHL
        into  v_achsvar
        FROM BUCHUNG b
        INNER JOIN MAUTKATEGORIE m
        ON b.KATEGORIE_ID = m.KATEGORIE_ID
        WHERE b.KENNZEICHEN = p_kennzeichen AND ROWNUM = 1; 
        CASE v_achsvar
            when '= 2' then v_achs := 2;
            when '= 3' then v_achs := 3;
            when '= 4' then v_achs := 4;
            when '>= 5' then v_achs := 5;
        end case;
        return v_achs;
        EXCEPTION 
            WHEN NO_DATA_FOUND then
            DBMS_OUTPUT.PUT_LINE('UNKNOWN_VEHICLE exception raised');
            raise UNKOWN_VEHICLE;
    END FindFahrzeugInBuchungTB;
    
    
    FUNCTION FindFahrzeugInFahrzeugTB(p_kennzeichen IN VARCHAR2)  
    RETURN NUMBER
    IS v_achs NUMBER;
    BEGIN 
    DBMS_OUTPUT.PUT_LINE('FindFahrzeugInFahrzeugTB Start');
        SELECT  f.ACHSEN
        into  v_achs
        FROM FAHRZEUG f
        WHERE f.KENNZEICHEN = p_kennzeichen AND ROWNUM = 1;
        return v_achs;
        EXCEPTION 
            WHEN NO_DATA_FOUND then
                return FindFahrzeugInBuchungTB(p_kennzeichen);     
    END FindFahrzeugInFahrzeugTB;
    
    
    FUNCTION IsManuel(p_kennzeichen FAHRZEUG.KENNZEICHEN%Type)
    Return boolean
    IS v_county number;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('IsManuel Start');
        SELECT count(*)
        INTO v_county
        FROM BUCHUNG
        WHERE KENNZEICHEN = p_kennzeichen AND B_ID = 1;
        IF v_county != 0 THEN
            return true;
        ELSE
            return false;
        END IF;    
    END IsManuel;
    
    
    FUNCTION PruefungAchszahlAV(p_achszahlFZ FAHRZEUG.ACHSEN%TYPE, p_achszahlUI FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS v_correctAchs boolean;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('PruefungAchszahlAV Start');
    IF p_achszahlFZ <= 4 THEN
        IF p_achszahlFZ = p_achszahlUI THEN
            v_correctAchs := True;
        ELSE
            v_correctAchs := False;
        END IF;
    ELSE
        IF p_achszahlFZ >= p_achszahlUI THEN
            v_correctAchs := TRUE;
        ELSE
            v_correctAchs := FALSE;
        END IF;
    END IF;
    return v_correctAchs;
    END PruefungAchszahlAV;
    
    
    FUNCTION PruefungAchszahlMV(p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE, p_achszahl FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS v_correctAchs boolean; 
        v_achszahlMK varchar2(100);
    BEGIN
    DBMS_OUTPUT.PUT_LINE('PruefungAchszahlMV Start');
    SELECT ACHSZAHL
    INTO v_achszahlMK
    FROM MAUTKATEGORIE ma INNER JOIN BUCHUNG b ON b.KATEGORIE_ID = ma.KATEGORIE_ID
    WHERE KENNZEICHEN = p_kennzeichen AND B_ID = 1;
    case v_achszahlMK
        when '= 2' then v_correctAchs := p_achszahl = 2;
        when '= 3' then v_correctAchs := p_achszahl = 3;
        when '= 4' then v_correctAchs := p_achszahl = 4;
        when '>= 5' then v_correctAchs := p_achszahl >= 5;
    end case;
    return v_correctAchs;
    END PruefungAchszahlMV;
    
    
    FUNCTION PruefungOffeneBuchungMV(p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE)
    Return boolean
    IS v_county number;   
    BEGIN
    DBMS_OUTPUT.PUT_LINE('PruefungOffeneBuchungMV Start');
    SELECT count(*)
    INTO v_county
    FROM BUCHUNG 
    WHERE KENNZEICHEN = p_kennzeichen AND B_ID = 1;
    IF v_county >= 0 THEN
        return true;
    ELSE 
        return false;
    END IF;
    END PruefungOffeneBuchungMV;
    
    
    FUNCTION parseAchsZahl(p_achszahl FAHRZEUG.ACHSEN%TYPE)
    RETURN  MAUTKATEGORIE.ACHSZAHL%TYPE
    IS v_achsen MAUTKATEGORIE.ACHSZAHL%TYPE; 
    BEGIN
    DBMS_OUTPUT.PUT_LINE('parseAchsZahl Start');
        case p_achszahl
        when 4 then
        v_achsen := '= 4';
        when 5 then
        v_achsen := '>= 5';
        end case;
        return v_achsen;
    END parseAchsZahl;
    
    
    FUNCTION GetMautKategorie(p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE,p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, p_achszahl FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.KATEGORIE_ID%TYPE
    IS v_kat MAUTKATEGORIE.KATEGORIE_ID%TYPE;  
        v_achsen MAUTKATEGORIE.achszahl%TYPE;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('GetMautKategorie Start');
      v_achsen:= parseAchsZahl(p_achszahl);
        SELECT mk.KATEGORIE_ID
        INTO v_kat
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = p_kennzeichen AND mk.ACHSZAHL =v_achsen;
        RETURN v_kat;
    END  GetMautKategorie;
    
    
    FUNCTION GetMautsatzJeKm(p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE,p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, p_achszahl FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE
    IS v_MautSatzJeKM MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
        v_achsen MAUTKATEGORIE.ACHSZAHL%TYPE;  
    BEGIN
    DBMS_OUTPUT.PUT_LINE('GetMautsatzJeKm Start');
        v_achsen:= parseAchsZahl(p_achszahl);
        SELECT mk.MAUTSATZ_JE_KM
        INTO  v_MautSatzJeKM
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = p_kennzeichen AND mk.ACHSZAHL = v_achsen;
        RETURN v_MautSatzJeKM;
        EXCEPTION 
         WHEN NO_DATA_FOUND then
            DBMS_OUTPUT.PUT_LINE('No data found');        
    END GetMautsatzJeKm;
    
    
    FUNCTION GetFzgID(p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE)
    RETURN  FAHRZEUGGERAT.FZG_ID%TYPE  
    IS v_fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
    BEGIN 
    DBMS_OUTPUT.PUT_LINE('GetFzgID Start');
        SELECT  fg.FZG_ID
        INTO v_fgID
        FROM FAHRZEUG f INNER JOIN FAHRZEUGGERAT fg
        ON f.FZ_ID  = fg.FZ_ID
        WHERE f.KENNZEICHEN  = p_kennzeichen;
        RETURN v_fgId;
     EXCEPTION
        WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No data found');
     END GetFzgID;
    
    
    FUNCTION GetAbschnittLaenge(p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE)
    Return MAUTABSCHNITT.LAENGE%TYPE 
    IS v_laenge MAUTABSCHNITT.LAENGE%TYPE;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('GetAbschnittLaenge Start');
    SELECT LAENGE
    INTO v_laenge
    FROM MAUTABSCHNITT
    WHERE ABSCHNITTS_ID = p_mautabschnitt;
    RETURN v_laenge;
    END GetAbschnittLaenge;
    
    -- Ende Funktionen ; Beginn Prozeduren --
    
    
    PROCEDURE BerechneKostenFuerAutomatischesVerfahren(p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE, p_achszahl FAHRZEUG.ACHSEN%TYPE )
    AS v_kosten MAUTERHEBUNG.KOSTEN%TYPE;
        v_mautsatzJeKm MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
        v_laenge MAUTABSCHNITT.LAENGE%TYPE ;
        v_fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
        v_katID  MautKategorie.KATEGORIE_ID%TYPE;
    BEGIN 
    DBMS_OUTPUT.PUT_LINE('BerechneKostenFuerAutomatischesVerfahren Start');
    v_mautsatzJeKm  := GetMautsatzJeKm(p_kennzeichen,p_mautabschnitt,p_achszahl);
    v_laenge := GetAbschnittLaenge(p_mautabschnitt);
    v_fgId := GetFzgID(p_kennzeichen);
    v_katID := GetMautKategorie(p_kennzeichen,p_mautabschnitt,p_achszahl);
    v_kosten := ((v_laenge / 1000) * v_mautsatzJeKm) / 100;
          DBMS_OUTPUT.PUT_LINE(v_kosten);
    INSERT INTO MAUTERHEBUNG  (MAUT_ID, ABSCHNITTS_ID, FZG_ID,KATEGORIE_ID, BEFAHRUNGSDATUM, KOSTEN)
    VALUES(1018, p_mautabschnitt, v_fgID, v_katID, CURRENT_TIMESTAMP, v_kosten);
    END BerechneKostenFuerAutomatischesVerfahren;
    
  
    PROCEDURE BerechneKostenFuerManuellesVerfahren(p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE,  p_achszahl FAHRZEUG.ACHSEN%TYPE, p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE)
    AS v_kat  NUMBER;
        v_buchungID  NUMBER;
        v_b_ID NUMBER;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('BerechneKostenFuerManuellesVerfahren Start');
         case p_achszahl
            when 4 then
                v_kat:=15;
                DBMS_OUTPUT.PUT_LINE('1');
                SELECT b.BUCHUNG_ID, b.B_ID 
                INTO v_buchungID, v_b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = v_kat AND b.KENNZEICHEN = p_kennzeichen AND ROWNUM = 1;
            when 3 then 
                v_kat:=14;
                DBMS_OUTPUT.PUT_LINE('2');
                SELECT b.BUCHUNG_ID, b.B_ID
                INTO v_buchungID, v_b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = v_kat AND b.KENNZEICHEN = p_kennzeichen AND ROWNUM = 1;
            else
                DBMS_OUTPUT.PUT_LINE('3');
                SELECT BUCHUNG_ID, B_ID
                INTO v_buchungID, v_b_ID
                FROM BUCHUNG 
                WHERE KENNZEICHEN = p_kennzeichen AND ABSCHNITTS_ID = p_mautabschnitt;
        end case;
        IF v_b_ID != 1 THEN
            DBMS_OUTPUT.PUT_LINE('4');
            RAISE ALREADY_CRUISED; 
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_buchungID);
            UPDATE BUCHUNG SET B_ID = 3, BEFAHRUNGSDATUM = CURRENT_TIMESTAMP WHERE BUCHUNG_ID = v_buchungID AND ROWNUM = 1;
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
    END BerechneKostenFuerManuellesVerfahren;
    
    
    PROCEDURE BERECHNEMAUT(p_mautabschnitt MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, p_achszahl FAHRZEUG.ACHSEN%TYPE, p_kennzeichen FAHRZEUG.KENNZEICHEN%TYPE) 
    AS v_dummy INTEGER; 
        v_fID  FAHRZEUG.FZ_ID%TYPE;
        v_achs  FAHRZEUG.ACHSEN%TYPE;
        v_kz FAHRZEUG.KENNZEICHEN%TYPE;
        v_aut BOOLEAN;
    BEGIN 
    DBMS_OUTPUT.PUT_LINE('BerechneMaut Start');
        v_achs := FindFahrzeugInFahrzeugTB(p_kennzeichen);
        IF IsManuel(p_kennzeichen) = TRUE THEN
            DBMS_OUTPUT.PUT_LINE('Is in the manuel procedure');
            IF PruefungAchszahlMV(p_kennzeichen, p_achszahl) = TRUE THEN
                DBMS_OUTPUT.PUT_LINE('Achszahl is correct');   
                BerechneKostenFuerManuellesVerfahren(p_mautabschnitt, p_achszahl, p_kennzeichen);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for manuel procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Is in the automatic procedure');
            IF PruefungAchszahlAV(v_achs, p_achszahl) = TRUE THEN
                DBMS_OUTPUT.PUT_LINE('Achszahl is correct');            
                BerechneKostenFuerAutomatischesVerfahren(p_mautabschnitt, p_kennzeichen, p_achszahl);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for automatic procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
        END IF;
    END BERECHNEMAUT;

END maut_service;

