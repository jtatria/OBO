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

import com.google.common.collect.ImmutableMap;
import org.apache.uima.fit.component.Resource_ImplBase;

import edu.columbia.incite.uima.tools.SplitCheck;

/**
 * SplitCheck implementation. This component tries to determine whether to split based on common 
 * patterns, and falls back to a probabilistic model based on Google Books's 2-gram dataset for 
 * the years covered by the Old Bailey Online archive.
 * 
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOSplitChecker extends Resource_ImplBase implements SplitCheck {

    /**
     * Split values for punctuation marks found as the last character of the left-most word.
     */
    public static final Map<Character,Boolean> leftPMap;
    
    /**
     * Split values for punctuation marks found as the first character of the right-most word.
     */
    public static final Map<Character,Boolean> rightPMap;
    
    static {
        Map<Character,Boolean> ltmp = new HashMap<>();
        ltmp.put( '!', true );
        ltmp.put( '"', true );
        ltmp.put( '#', true );
        ltmp.put( '%', true );
        ltmp.put( '&', true );
        ltmp.put( '\'', true );
        ltmp.put( '(', false );
        ltmp.put( ')', true );
        ltmp.put( '*', true );
        ltmp.put( '+', true );
        ltmp.put( ',', true );
        ltmp.put( '-', false );
        ltmp.put( '.', true );
        ltmp.put( '/', false );
        ltmp.put( ':', true );
        ltmp.put( ';', true );
        ltmp.put( '>', true );
        ltmp.put( '?', true );
        ltmp.put( '[', false );
        ltmp.put( ']', true );
        ltmp.put( '{', false );
        ltmp.put( '}', true );
        ltmp.put( '~', true );
        ltmp.put( '£', true );
        ltmp.put( '¼', true );
        ltmp.put( '½', true );
        ltmp.put( '¾', true );
        ltmp.put( '—', false );
        ltmp.put( '”', true );
        ltmp.put( '„', true );
        ltmp.put( '†', true );
        ltmp.put( '•', true );
        ltmp.put( '…', true );
        ltmp.put( '₤', true );
        ltmp.put( '✗', true );
        leftPMap = ImmutableMap.copyOf( ltmp );

        Map<Character,Boolean> rtmp = new HashMap<>();
        rtmp.put( '!', false );
        rtmp.put( '"', true );
        rtmp.put( '#', true );
        rtmp.put( '%', true );
        rtmp.put( '&', true );
        rtmp.put( '\'', true );
        rtmp.put( '(', true );
        rtmp.put( ')', false );
        rtmp.put( '*', true );
        rtmp.put( '+', true );
        rtmp.put( ',', false );
        rtmp.put( '-', false );
        rtmp.put( '.', false );
        rtmp.put( '/', false );
        rtmp.put( ':', false );
        rtmp.put( ';', false );
        rtmp.put( '>', true );
        rtmp.put( '?', false );
        rtmp.put( '[', true );
        rtmp.put( ']', false );
        rtmp.put( '{', true );
        rtmp.put( '}', false );
        rtmp.put( '~', true );
        rtmp.put( '£', true );
        rtmp.put( '¼', true );
        rtmp.put( '½', true );
        rtmp.put( '¾', true );
        rtmp.put( '—', false );
        rtmp.put( '”', true );
        rtmp.put( '„', true );
        rtmp.put( '†', true );
        rtmp.put( '•', true );
        rtmp.put( '…', true );
        rtmp.put( '₤', true );
        rtmp.put( '✗', true );
        rightPMap = ImmutableMap.copyOf( rtmp );
    }
    
    private boolean dump = false;
    private final OBOModel oboModel = new OBOModel();
    private Map<String,AtomicInteger> stats = new HashMap<>();

    @Override
    public boolean split( String pre, String pos, String tag ) {    
        Rule rule = getRule( pre, pos );
        
        boolean split = false;
        switch( rule ) {
            // punct collisions are always split
            case PCOLL  : split = true;                                                   break;
            // split depending on punctuation
            case PLEFT  : split = leftPMap.get( pre.charAt( pre.length() - 1 ) );         break;
            case PRIGHT : split = rightPMap.get( pos.charAt( 0 ) );                       break;
            // ordinal and money suffixes are never split
            case ORDNL  : case MONEY: split = false;                                      break;
            // words are checked against dictionary.
            case WORD   : split = checkWord( pre, pos, tag );                             break;
            // conservative for now: unknowns are not split.
            case MISS   : split = checkOther( pre, pos, tag );                            break;
            default: throw new AssertionError( rule.name() );    
        }

        if( dump ) {
            System.out.printf(
                "@@@\t%s\t%s\t%s\t%s\t%s\n",
                pre, pos, tag, rule, split ? "SPLIT" : "JOIN"
            );
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
        // left smells like punctuation
        boolean lP   = !Character.isAlphabetic( pre.charAt( pre.length() - 1 ) ) &&
            !Character.isDigit( pre.charAt( pre.length() - 1 ) );
        // right smells like punctuation
        boolean rP   = !Character.isAlphabetic( pos.charAt( 0 ) ) &&
            !Character.isDigit( pos.charAt( 0 ) );
        // looks like regular words
        boolean word = pre.matches( "^(.*\\W)?[a-zA-Z-]+$" ) &&
            pos.matches( "^[a-zA-Z-]+(\\W.*)?$" );
        // split ordinal number
        boolean ordn = ( pre.matches( ".*(1[123]|[0456789])$" ) && pos.matches( "(?i)^th.*" ) ) ||
            ( pre.matches( ".*1$" ) && pos.matches( "(?i)st.*") ) ||
            ( pre.matches( ".*2$" ) && pos.matches( "(?i)nd.*") ) ||
            ( pre.matches( ".*3$" ) && pos.matches( "(?i)rd.*") );
        // split money amounts
        boolean mney = pre.matches( ".*[0-9]$" ) && pos.matches( "(?i)(l|d|s)\\.?.*" );
        
        Rule rule;
        if( lP && rP ) rule  = Rule.PCOLL;  // punct on both ends, collision
        else if( lP ) rule   = Rule.PLEFT;  // left punct.
        else if( rP ) rule   = Rule.PRIGHT; // right punct.
        else if( word ) rule = Rule.WORD;   // regular word.
        else if( ordn ) rule = Rule.ORDNL;  // ordinal.
        else if( mney ) rule = Rule.MONEY;  // money.
        else rule = Rule.MISS; // no idea wtf this is.
        
        return rule;
    }

    /**
     * Placeholder method for {@link OBOSplitChecker.Rule.MISS} cases. Default implementation 
     * returns {@code false}
     * 
     * @param pre A string representing the first (leftmost) char sequence.
     * @param pos A string representing the second (rightmost) char sequence.
     * @param tag The name of any XML tags found in between the two stream segments.
     * 
     * @return {@code false}.
     */
    public boolean checkOther( String pre, String pos, String tag ) {
        return false;
    }
    
    /**
     * "Rules" for deciding which strategy to use in determining whether the given strings should 
     * be split.
     */
    public enum Rule {
        /** Punct collision: always split **/
        PCOLL,
        /** Punct on left: check leftMap based on last char in pre **/
        PLEFT,
        /** Punct on right: check rightMap based on first char in pos **/
        PRIGHT,
        /** Ordinal: never split **/
        ORDNL,
        /** Money: never split **/
        MONEY,
        /** Regular word: query model. See {@link OBOModel} **/
        WORD,
        
        /**
         * Missing: never split, but override 
         * {@link #checkOther(java.lang.String, java.lang.String, java.lang.String)} for additional
         * logic
         **/
        MISS,
    }

}
