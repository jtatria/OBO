/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
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