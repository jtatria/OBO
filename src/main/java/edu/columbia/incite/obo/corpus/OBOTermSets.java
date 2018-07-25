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
package edu.columbia.incite.obo.corpus;

import java.util.Arrays;

import org.apache.lucene.util.automaton.Automata;
import org.apache.lucene.util.automaton.Automaton;
import org.apache.lucene.util.automaton.Operations;
import org.apache.lucene.util.automaton.RegExp;

import edu.columbia.incite.corpus.TermSet;
import edu.columbia.incite.util.Automatons;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class OBOTermSets {
    
    /** Arbitrary punctuation marks (missed by POS tagger) **/
    public static final TermSet L_PUNCT = new TermSet(
        "([`!\"#$%&()*+,-./:;<=>?@|—\\\\~{}_^'¡£¥¦§«°±³·»¼½¾¿–—‘’‚“”„†•…₤™✗]+|-[lr][rs]b-)",
        "L_PUNCT"
    );
    
    /** Two-letter-or-less lemmas **/
    public static final TermSet L_SHORT = new TermSet(
        ".{0,2}", 
        "L_SHORT"
    );
    
    /** British money amounts **/
    public static final TermSet L_MONEY = new TermSet(
        "[0-9]+-?[lds]\\.?(-note)?",
        "L_MONEY"
    );
    
    /** Ordinal numbers **/
    public static final TermSet L_ORD;
    static{
        L_ORD = new TermSet(
            "[0-9]*((1[123]|[0456789])th|1st|2nd|3rd)",
            "L_ORD"
        );
    }
    
    /** Any number **/
    public static final TermSet L_NUMBER;
    static {
        Automaton unitAu = Automatons.union( new String[]{
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
        } );
        
        Automaton tensAu = Automatons.union( new String[]{
            "twenty",
            "thirty",
            "forty",
            "fifty",
            "sixty",
            "seventy",
            "eighty",
            "ninety",
        } );
        
        Automaton teenAu = Automatons.union( new String[]{
            "ten",
            "eleven",
            "twelve",
            "thirteen",
            "fourteen",
            "fifteen",
            "sixteen",
            "seventeen",
            "eighteen",
            "nineteen",
        } );
        
        Automaton tensUnitAu = Operations.concatenate( Arrays.asList( new Automaton[] {
            tensAu, Automata.makeString( "-" ), unitAu 
        } ) );
        
        Automaton literals = Operations.union( Arrays.asList( new Automaton[]{
            unitAu, tensAu, tensUnitAu, teenAu
        } ) );
        Automaton ints = new RegExp( "[0-9]+" ).toAutomaton();
        Automaton frac = new RegExp( "([0-9]+ )?[0-9]+/[0-9]+" ).toAutomaton();
        Automaton decs = new RegExp( "([0-9]+)?[.,][0-9]+" ).toAutomaton();
        Automaton numerics = Operations.union(
            Arrays.asList( new Automaton[]{ literals, ints, frac, decs } )
        );
        L_NUMBER = new TermSet( numerics, "L_NUMBER" );
    }
    
    /** Weights **/
    public static final TermSet L_WEIGHT = new TermSet(
        "[0-9]+(lb|oz)s?\\.?", "L_WEIGHT"
    );
    
    /** Lengths **/
    public static final TermSet L_LENGTH = new TermSet(
        "[0-9]+(in|-inch|ft|m)s?\\.?", "L_LENGTH"
    );

}