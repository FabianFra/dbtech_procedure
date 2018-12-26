package de.htwberlin.mauterhebung;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.sql.Connection;
import de.htwberlin.exceptions.DataException;
import de.htwberlin.mautProzedur.IMautProzedur;
import de.htwberlin.mautProzedur.MautProzedurImpl;

/**
 * Die Klasse realisiert die Mauterhebung.
 * 
 * @author Patrick Dohmeier
 */
public class MautProcedureImpl implements IMauterhebung {

	private static final Logger L = LoggerFactory.getLogger(MautProcedureImpl.class);
	private Connection connection;
	private IMautProzedur mautProzedur = new MautProzedurImpl();

	@Override
	public void setConnection(Connection connection) {
		this.connection = connection;
	}

	private Connection getConnection() {
		if (connection == null) {
			throw new DataException("Connection not set");
		}
		return connection;
	}

	@Override
	public void berechneMaut(int mautAbschnitt, int achszahl, String kennzeichen) {

		((MautProzedurImpl) mautProzedur).setConnection(connection);

		mautProzedur.berechneMaut(mautAbschnitt, achszahl, kennzeichen);

	}

}
