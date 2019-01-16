/*Bitte achte drauf, dass die DBMS-Ausgabe aktiviert ist. (Ansicht -> DBMS-Ausgabe)*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE BODY maut_service IS
 
  
  FUNCTION FindFahrzeugInBuchungTB(p_kennzeichen IN VARCHAR2)
    RETURN NUMBER
    IS v_achs VARCHAR2(5);
    BEGIN
        SELECT  m.ACHSZAHL
        into  v_achs
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
    IS v_achs NUMBER;
    BEGIN 
        
        SELECT  f.ACHSEN
        into  v_achs
        FROM Fahrzeug f
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
    
        return v_achs;
    
        EXCEPTION 
            WHEN NO_DATA_FOUND then
                return FindFahrzeugInBuchungTB(p_kennzeichen);   
         
    END FindFahrzeugInFahrzeugTB;
    
    FUNCTION IsManuel(p_kennzeichen FAHRZEUG.KENNZEICHEN%Type)
    Return boolean
    IS
    v_county number;
    BEGIN
        SELECT count(*)
        INTO v_county
        FROM BUCHUNG
        WHERE Kennzeichen = p_kennzeichen AND B_ID = 1;
        
        IF v_county != 0 THEN
            return true;
        Else
            return false;
        END IF;      
    END IsManuel;
    
    
    FUNCTION PruefungAchszahlAV(p_achszahlFZ FAHRZEUG.ACHSEN%TYPE, p_achszahlUI FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS v_correctAchs boolean;
    
    BEGIN
    
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
    
    FUNCTION PruefungAchszahlMV(p_kennzeichen FAHRZEUG.KENNZEICHEN%Type, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)
    Return boolean
    IS 
    v_correctAchs boolean; 
    v_achszahlMK varchar2(100);
    BEGIN
    
    
    
    SELECT ACHSZAHL
    INTO v_achszahlMK
    FROM BUCHUNG b INNER JOIN MAUTKATEGORIE ma ON b.KATEGORIE_ID = ma.KATEGORIE_ID
    WHERE Kennzeichen = p_kennzeichen AND B_ID = 1;
    
    case v_achszahlMK
        when '= 2' then v_correctAchs := P_ACHSZAHL = 2;
        when '= 3' then v_correctAchs := P_ACHSZAHL = 3;
        when '= 4' then v_correctAchs := P_ACHSZAHL = 4;
        when '>= 5' then v_correctAchs := P_ACHSZAHL >= 5;
    end case;
    
    return v_correctAchs;
    
    END PruefungAchszahlMV;
    
    FUNCTION PruefungOffeneBuchungMV(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    Return boolean
    IS 
    v_county number;
        
    BEGIN
    
    SELECT count(*)
    INTO v_county
    FROM BUCHUNG 
    WHERE KENNZEICHEN = P_KENNZEICHEN AND B_ID = 1;
    
    IF v_county >= 0 THEN
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
     v_achsen MAUTKATEGORIE.achszahl%TYPE;
    BEGIN
         case P_ACHSZAHL
        when 4 then
        v_achsen := '= 4';
        when 5 then
        v_achsen := '>= 5';
        
        end case;
        
        return v_achsen;
    END parseAchsZahl;
    
    FUNCTION GetMautKategorie(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE,P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.KATEGORIE_ID%TYPE
   
    IS
    v_kat MAUTKATEGORIE.KATEGORIE_ID%TYPE;
    v_achsen MAUTKATEGORIE.achszahl%TYPE;
    
    BEGIN
      v_achsen:= parseAchsZahl(P_ACHSZAHL);
         SELECT mk.KATEGORIE_ID
        INTO v_kat
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND mk.ACHSZAHL =v_achsen;
        return v_kat;
    
    END  GetMautKategorie;
    
    function GetMautsatzJeKm(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE,P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE)    
    RETURN MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE
   
    IS
    v_MautSatzJeKM MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
    v_achsen MAUTKATEGORIE.achszahl%TYPE;
    
    BEGIN
       v_achsen:= parseAchsZahl(P_ACHSZAHL);
    
        
        DBMS_OUTPUT.PUT_LINE(v_achsen);
        DBMS_OUTPUT.PUT_LINE('START GetMautsatzJeKm');
        SELECT mk.MAUTSATZ_JE_KM
        INTO  v_MautSatzJeKM
        FROM FAHRZEUG f
        INNER JOIN MAUTKATEGORIE mk  
        ON f.SSKL_ID = mk.SSKL_ID
        WHERE f.KENNZEICHEN = P_KENNZEICHEN AND mk.ACHSZAHL =v_achsen;
        
        return v_MautSatzJeKM;
        
        EXCEPTION 
         WHEN NO_DATA_FOUND then
            raise NO_DATA_FOUND;
            DBMS_OUTPUT.PUT_LINE('no data found');
    
        
    END GetMautsatzJeKm;
    
      FUNCTION GetFzgID(P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    RETURN  FAHRZEUGGERAT.FZG_ID%TYPE  IS
     v_fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
     BEGIN
     
        SELECT  fg.fzg_id
        into v_fgID
        FROM FAHRZEUG f INNER JOIN FAHRZEUGGERAT fg
        ON f.fz_id  = fg.fz_ID
        WHERE f.KENNZEICHEN  = P_KENNZEICHEN;
    
        return v_fgId;
        
     EXCEPTION
        WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No data found');
     END GetFzgID;
    
   FUNCTION GetAbschnittLaenge(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE)
    Return MAUTABSCHNITT.LAENGE%TYPE IS
    v_laenge MAUTABSCHNITT.LAENGE%TYPE;
    
    BEGIN
      DBMS_OUTPUT.PUT_LINE('123test');
    SELECT LAENGE
    INTO v_laenge
    FROM MAUTABSCHNITT
    WHERE ABSCHNITTS_ID = P_MAUTABSCHNITT;
    
    return v_laenge;
    
    END GetAbschnittLaenge;
    
  
    
    PROCEDURE BerechneKostenFuerAutomatischesVerfahren(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE )
    AS
    v_kosten MAUTERHEBUNG.KOSTEN%TYPE;
   
    v_mautsatzJeKm MAUTKATEGORIE.MAUTSATZ_JE_KM%TYPE;
    v_laenge MAUTABSCHNITT.LAENGE%TYPE ;
    v_fgId  FAHRZEUGGERAT.FZG_ID%TYPE;
    v_katID  MautKategorie.KATEGORIE_ID%TYPE;
    BEGIN 
    v_mautsatzJeKm  := GetMautsatzJeKm(P_KENNZEICHEN,P_MAUTABSCHNITT,P_ACHSZAHL);
    v_laenge := GetAbschnittLaenge(P_MAUTABSCHNITT);
    v_fgId := GetFzgID(P_KENNZEICHEN);
  
    v_katID := GetMautKategorie(P_KENNZEICHEN,P_MAUTABSCHNITT,P_ACHSZAHL);
    v_kosten := ((v_laenge / 1000) * v_mautsatzJeKm) / 100;
         
        INSERT INTO MAUTERHEBUNG  (MAUT_ID,ABSCHNITTS_ID,FZG_ID,KATEGORIE_ID,BEFAHRUNGSDATUM,KOSTEN)
        VALUES(1018,P_MAUTABSCHNITT,v_fgID,v_katID,CURRENT_TIMESTAMP,v_kosten);
    
    END BerechneKostenFuerAutomatischesVerfahren;
    
  
    
    
  
    PROCEDURE BerechneKostenFuerManuellesVerfahren(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE,  P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE)
    AS 
    v_kat  NUMBER;
    v_buchungID  NUMBER;
    v_b_ID NUMBER;
    BEGIN
         case P_ACHSZAHL
            when 4 then
                v_kat:=15;
          
                SELECT b.BUCHUNG_ID, b.B_ID 
                into v_buchungID, v_b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = v_kat AND b.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
                
            when 3 then 
                v_kat:=14;
   
                SELECT b.BUCHUNG_ID, b.B_ID
                into v_buchungID, v_b_ID  
                FROM BUCHUNG b
                WHERE b.KATEGORIE_ID = v_kat AND b.KENNZEICHEN = P_KENNZEICHEN AND ROWNUM = 1;
            else
 
                SELECT BUCHUNG_ID, B_ID
                into v_buchungID, v_b_ID
                FROM BUCHUNG 
                WHERE KENNZEICHEN = P_KENNZEICHEN AND ABSCHNITTS_ID = P_MAUTABSCHNITT;
        end case;
    
        if v_b_ID != 1 then
            raise ALREADY_CRUISED;
            
        else
            UPDATE BUCHUNG SET b_id = 3, BEFAHRUNGSDATUM = CURRENT_TIMESTAMP WHERE buchung_id = v_buchungID AND ROWNUM = 1; /*b_id ist die variable in der Tabelle*/
        END IF;
        
        EXCEPTION
        WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No data found');
              
    END BerechneKostenFuerManuellesVerfahren;
    
    
    
    
    PROCEDURE BERECHNEMAUT(P_MAUTABSCHNITT MAUTABSCHNITT.ABSCHNITTS_ID%TYPE, P_ACHSZAHL FAHRZEUG.ACHSEN%TYPE, P_KENNZEICHEN FAHRZEUG.KENNZEICHEN%TYPE) AS 
    
    v_fID  FAHRZEUG.FZ_ID%TYPE;
    v_achs  FAHRZEUG.ACHSEN%TYPE;
  
 
    
    
    BEGIN 
        v_achs := FindFahrzeugInFahrzeugTB(P_KENNZEICHEN);
        
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
            
            IF PruefungAchszahlAV(v_achs, P_ACHSZAHL) = TRUE THEN
                DBMS_OUTPUT.PUT_LINE('ACHZAHL is correct');            
                BerechneKostenFuerAutomatischesVerfahren(P_MAUTABSCHNITT, P_KENNZEICHEN, P_ACHSZAHL);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INVALID_VEHICLE_DATA raised for automatic procedure');
                RAISE INVALID_VEHICLE_DATA;
            END IF;
            
        END IF;
        
    END BERECHNEMAUT;

END maut_service;

