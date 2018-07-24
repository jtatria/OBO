/* 
 * Copyright (C) 2017 José Tomás Atria <jtatria at gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package edu.columbia.incite.obo.uima.io;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import edu.columbia.incite.uima.tools.InciteTextFilter;
import edu.columbia.incite.uima.tools.SplitCheck;

/**
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOTextFilter extends InciteTextFilter implements SplitCheck {

    private static final Map<Character,Boolean> leftPMap = new HashMap<>();
    private static final Map<Character,Boolean> rightPMap = new HashMap<>();
    static {
        leftPMap.put( '!', true );
        leftPMap.put( '"', true );
        leftPMap.put( '#', true );
        leftPMap.put( '%', true );
        leftPMap.put( '&', true );
        leftPMap.put( '\'', true );
        leftPMap.put( '(', false );
        leftPMap.put( ')', true );
        leftPMap.put( '*', true );
        leftPMap.put( '+', true );
        leftPMap.put( ',', true );
        leftPMap.put( '-', false );
        leftPMap.put( '.', true );
        leftPMap.put( '/', false );
        leftPMap.put( ':', true );
        leftPMap.put( ';', true );
        leftPMap.put( '>', true );
        leftPMap.put( '?', true );
        leftPMap.put( '[', false );
        leftPMap.put( ']', true );
        leftPMap.put( '{', false );
        leftPMap.put( '}', true );
        leftPMap.put( '~', true );
        leftPMap.put( '£', true );
        leftPMap.put( '¼', true );
        leftPMap.put( '½', true );
        leftPMap.put( '¾', true );
        leftPMap.put( '—', false );
        leftPMap.put( '”', true );
        leftPMap.put( '„', true );
        leftPMap.put( '†', true );
        leftPMap.put( '•', true );
        leftPMap.put( '…', true );
        leftPMap.put( '₤', true );
        leftPMap.put( '✗', true );

        rightPMap.put( '!', false );
        rightPMap.put( '"', true );
        rightPMap.put( '#', true );
        rightPMap.put( '%', true );
        rightPMap.put( '&', true );
        rightPMap.put( '\'', true );
        rightPMap.put( '(', true );
        rightPMap.put( ')', false );
        rightPMap.put( '*', true );
        rightPMap.put( '+', true );
        rightPMap.put( ',', false );
        rightPMap.put( '-', false );
        rightPMap.put( '.', false );
        rightPMap.put( '/', false );
        rightPMap.put( ':', false );
        rightPMap.put( ';', false );
        rightPMap.put( '>', true );
        rightPMap.put( '?', false );
        rightPMap.put( '[', true );
        rightPMap.put( ']', false );
        rightPMap.put( '{', true );
        rightPMap.put( '}', false );
        rightPMap.put( '~', true );
        rightPMap.put( '£', true );
        rightPMap.put( '¼', true );
        rightPMap.put( '½', true );
        rightPMap.put( '¾', true );
        rightPMap.put( '—', false );
        rightPMap.put( '”', true );
        rightPMap.put( '„', true );
        rightPMap.put( '†', true );
        rightPMap.put( '•', true );
        rightPMap.put( '…', true );
        rightPMap.put( '₤', true );
        rightPMap.put( '✗', true );
    }
    
    private boolean dump = true;
    private final OBOModel oboModel = new OBOModel();
    private final Map<String,AtomicInteger> stats = new HashMap<>();
    
    @Override
    public boolean split( String pre, String pos, String tag ) {
    
        Rule rule = getRule( pre, pos );
        
        boolean split = false;
        switch( rule ) {
            case PCOLL  : split = true;                                                   break;
            case PLEFT  : split = leftPMap.get( pre.charAt( pre.length() - 1 ) );         break;
            case PRIGHT : split = rightPMap.get( pos.charAt( 0 ) );                       break;
            case ORDNL  : case MONEY: split = false;                                      break;
            case WORD   : split = checkWord( pre, pos, tag );                             break;
            case MISS   : split = checkOther( pre, pos, tag );                            break;
            default: throw new AssertionError( rule.name() );    
        }
        
        if( dump ) {
            System.out.printf( "@@@\t%s\t%s\t%s\t%s\t%s\n", pre, pos, tag, rule, split ? "SPLIT" : "JOIN" );
        }
        
        if( stats != null ) {
            String key = rule + "-" + ( split ? "SPLIT" : "JOIN" );
            stats.computeIfAbsent( key, s -> new AtomicInteger() ).incrementAndGet();
        }
        
        return split;
    }
    
    private boolean checkWord( String pre, String pos, String tag ) {
        if( tag.equals( "lb" ) ) return false;
        
        if( pre.matches( ".+'(s|d|t)" ) ) return true;
        
        String lT = pre.replaceAll( "^.*\\W", "" );
        String rT = pos.replaceAll( "\\W.*$", "" );
        
        if( "".equals( lT ) || "".equals( rT ) ) {
            return false;
        }
        
        double lW = oboModel.p( lT );
        double rW = oboModel.p( rT );
        double jW = oboModel.p( lT + rT );

        if( jW < 0 && ( lW >= 0 || rW >= 0 ) ) return true;
        if( jW >= 0 && ( lW < 0 || rW < 0 ) ) return false;
        
        if( lW < 0 || rW < 0 ) {
            return jW < 0;
        }
        
        return ( rW * lW ) > jW;
    }
    
    private Rule getRule( String pre, String pos ) {
        boolean lP   = !Character.isAlphabetic( 
            pre.charAt( pre.length() - 1 ) ) && !Character.isDigit( pre.charAt( pre.length() - 1 ) 
        );
        
        boolean rP   = !Character.isAlphabetic( pos.charAt( 0 ) ) &&
            !Character.isDigit( pos.charAt( 0 ) );
        
        boolean word = pre.matches( "^(.*\\W)?[a-zA-Z-]+$" ) &&
            pos.matches( "^[a-zA-Z-]+(\\W.*)?$" );
        
        boolean ordn = ( pre.matches( ".*(1[123]|[0456789])$" ) && pos.matches( "(?i)^th.*" ) ) ||
            ( pre.matches( ".*1$" ) && pos.matches( "(?i)st.*") ) ||
            ( pre.matches( ".*2$" ) && pos.matches( "(?i)nd.*") ) ||
            ( pre.matches( ".*3$" ) && pos.matches( "(?i)rd.*") );
        
        boolean mney = pre.matches( ".*[0-9]$" ) && pos.matches( "(?i)(l|d|s)\\.?.*" );
        
        Rule rule;
        if( lP && rP ) rule  = Rule.PCOLL;
        else if( lP ) rule   = Rule.PLEFT;
        else if( rP ) rule   = Rule.PRIGHT;
        else if( word ) rule = Rule.WORD;
        else if( ordn ) rule = Rule.ORDNL;
        else if( mney ) rule = Rule.MONEY;
        else rule = Rule.MISS;
        
        return rule;
    }

    private boolean checkOther( String pre, String pos, String tag ) {
        return false;
    }
    
    public enum Rule {
        /** Punctuation collision **/
        PCOLL,
        /** Punctuation on left-side end **/
        PLEFT,
        /** Punctuation on right-side begin **/
        PRIGHT,
        /** Ordinal number **/
        ORDNL,
        /** Money ammount **/
        MONEY,
        /** Regular word **/
        WORD,
        /** Unknown string **/
        MISS,
    }
    
}
