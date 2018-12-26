package de.htwberlin.exceptions;

/**
 * Die Exception ist eine Oberklasse für alle DAO-Exceptions.
 *
 * @author Martin Kempa
 */
public /* abstract */ class DaoException extends RuntimeException {

    /** Die Konstante identifiziert die Klassenversion. */
    private static final long serialVersionUID = 1L;

    /**
     * Der Konstruktor erzeugt eine DaoException.
     */
    public DaoException() {
    }

    /**
     * Der Konstruktor erzeugt eine DaoException und verweist
     * auf ein Throwable t.
     * @param t hält ein Throwable.
     */
    public DaoException(Throwable t) {
        super(t);
    }

}
