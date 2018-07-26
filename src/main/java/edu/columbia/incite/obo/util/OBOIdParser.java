/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.util;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class that validates Old Bailey Online id attributes.
 * 
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOIdParser {
    
    /**
     * OBO Id parts for use as group indices over a regular expression matcher.
     */
    public enum Parts {
        // Form 1
        DOCUMENT_1( 2 ),
        DOCSUFFIX_PART( 3 ),
        DOC_INDEX_1( 4 ),
        ENTITY_PART( 5 ),
        ENTITY( 6 ),
        ENTITY_TYPE_PART( 7 ),
        ENTITY_INDEX( 8 ),
        CHARGE_PART( 9 ),
        CHARGE( 10 ),
        CHARGE_INDEX( 11 ),
        // Form 2
        DEF_NAME( 12 ),
        DEF_INDEX( 13 ),
        DOC_INDEX_2( 14 ),
        DOCUMENT_2( 15 );

        private final Integer group;

        private Parts( Integer value ) {
          this.group = value;
        }
    }
    
    /**
     * OBO Id Format 1: 
     * {@code ^[a-z]?[0-9]{8}[a-z]?-[0-9]{1,4}[a-z]?-[a-z]+?-?[0-9]{1,4}[a-z]?-c[0-9]{1,4}$ }
     */
    public static final int FORMAT1 = 0;

    /**
     * OBO Id Format 2:
     * {@code ^def-[0-9]{1,4}[a-z]?-[0-9]{1,4}[a-z]?-[0-9]{8}$ }
     */
    public static final int FORMAT2 = 1;
    
    private static final String docPart = "([a-z]?[0-9]{1,8}[a-z]?)";
    private static final Pattern docRex = Pattern.compile( docPart );
    private static final String indPart = "([0-9]{1,4}[a-z]?)";
    private static final Pattern indRex = Pattern.compile( indPart );
    private static final String defPart = "(def([0-9]{1,4}[a-z]?))";
    private static final Pattern defRex = Pattern.compile( defPart );
    private static final String entPart = "(([a-z]+?-?)([0-9]{1,4}[a-z]?))";
    private static final Pattern basRex = Pattern.compile( entPart );
    private static final String chaPart = "(c([0-9]{1,4}))";
    private static final Pattern chaRex = Pattern.compile( chaPart );
    
    /**
     * String representation of the regular expression for formats.
     */
    public static final String FORMAT = String.format(
        "(^%1$s(-%2$s)?(-%4$s)?(-%5$s)?$|^%3$s-%2$s-%1$s$)"
        , new Object[]{ docPart, indPart, defPart, entPart, chaPart }
    );
    
    private static final Pattern formatRex = Pattern.compile( FORMAT, Pattern.CASE_INSENSITIVE );
    
    /**
     * Reconstruct an OBO Id from its parsed parts.
     * @param parts     A map produced by {@link #getParts(java.lang.String)}
     * @return          A string that should be equal to the original id, built from parsed parts.
     */
    public static String buildId( Map<Parts,String> parts ) {
        int format = getFormat( parts );
        StringBuilder golem = new StringBuilder();
        if( format == FORMAT1 ) { // Format 1
            golem.append( parts.get( Parts.DOCUMENT_1 ) );
            if( parts.get( Parts.DOC_INDEX_1 ) != null ) { // Document indices
                golem.append( "-" ).append( parts.get( Parts.DOC_INDEX_1 ) );
            }
            if( parts.get( Parts.ENTITY_PART ) != null ) { // Entity names
                golem.append( "-" ).append( parts.get(Parts.ENTITY_TYPE_PART ) )
                    .append( parts.get(Parts.ENTITY_INDEX ) );
            }
            if( parts.get( Parts.CHARGE_PART ) != null ) { // Charge ids.
                golem.append( "-c" ).append( parts.get( Parts.CHARGE_INDEX ) );
            }
        } else if( format == FORMAT2 ) { // Format 2
            golem.append( "def" ).append( parts.get( Parts.DEF_INDEX ) )
                .append( "-" ).append( parts.get( Parts.DOC_INDEX_2 ) )
                .append( "-" ).append( parts.get( Parts.DOCUMENT_2 ) );
        }
        return golem.toString(); // IT'S ALIVE!
    }
    
    /**
     * Compare the given id with the string constructed from re-assembling the parsed parts.
     * Return an integer equal to the Levenshtein distance between the two strings.
     * @param id    An OBO id string.
     * @return      An integer vallue with the Levenshtein distance between the id and its 
     *              reconstructed version.
     */
    public static int validate( String id ) {
        Map<Parts,String> parts = getParts( id );
        return validate( id, parts );
    }
    
    public static int validate( String id, Map<Parts,String> parts ) {
        String golem = buildId( parts );
        return levenshteinDistance( id, golem );
    }

    /**
     * Get id parts from a given id string.
     * @param id    An OBO id string.
     * @return      A map with {@link Parts} keys and string values.
     */
    public static Map<Parts,String> getParts( String id ) {
        Matcher m = formatRex.matcher( id );
        Map<Parts,String> parts = null;
        if( m.find() ) {
            parts = new HashMap<>();
            for( Parts part : Parts.values() ) {
                parts.put( part, m.group(part.group ) );
            }
        }    
        return parts;
    }
    
    /**
     * Get the format for this id.
     * See {@link #FORMAT1} and {@link #FORMAT2}.
     * 
     * @param id    An OBO id string
     * @return      An integer corresponding to the id's format.
     */
    public static int getFormat( String id ) {
        return getFormat( getParts( id ) );
    }
    
    /**
     * Get the format for this id.
     * See {@link #FORMAT1} and {@link #FORMAT2}.
     * 
     * @param parts A {@code Map<Parts,String>} with id parts.
     * @return      An integer corresponding to the id's format.
     */
    public static int getFormat( Map<Parts,String> parts ) {
        if( parts.get( Parts.DOCUMENT_1 ) != null ) {
            return FORMAT1;
        } else if( parts.get( Parts.DOCUMENT_2 ) != null ) {
            return FORMAT2;
        } else return 0;
    }
    
    /**
     * Naive implementation of Levenshtein's distance.
     * Compute a transformation distance between two strings according to
     * <a href=http://en.wikipedia.org/wiki/Levenshtein_distance>Levenshtein's algorithm<a/>.
     * Implementation taken from
     * <a href=http://en.wikibooks.org/w/index.php?title=Algorithm_Implementation/Strings/Levenshtein_distance&oldid=2841703#Java>here<a/>,
     * licensed under <a href=http://creativecommons.org/licenses/by-sa/3.0/>CC BY-SA 3.0</a>.
     *
     * @param s0 A string.
     * @param s1 Another string.
     *
     * @return Transformation cost of turning s0 into s1. If s0.equals( s1 ), this is 0.
     */
    public static int levenshteinDistance( String s0, String s1 ) {
        int len0 = s0.length() + 1;
        int len1 = s1.length() + 1;

        // the array of distances                                                       
        int[] cost = new int[len0];
        int[] newcost = new int[len0];

        // initial cost of skipping prefix in String s0                                 
        for( int i = 0; i < len0; i++ ) {
            cost[i] = i;
        }

        // dynamically computing the array of distances                                  
        // transformation cost for each letter in s1                                    
        for( int j = 1; j < len1; j++ ) {
            // initial cost of skipping prefix in String s1                             
            newcost[0] = j;

            // transformation cost for each letter in s0                                
            for( int i = 1; i < len0; i++ ) {
                // matching current letters in both strings                             
                int match = ( s0.charAt( i - 1 ) == s1.charAt( j - 1 ) ) ? 0 : 1;

                // computing cost for each transformation                               
                int cost_replace = cost[i - 1] + match;
                int cost_insert = cost[i] + 1;
                int cost_delete = newcost[i - 1] + 1;

                // keep minimum cost                                                    
                newcost[i] = Math.min( Math.min( cost_insert, cost_delete ), cost_replace );
            }

            // swap cost/newcost arrays                                                 
            int[] swap = cost;
            cost = newcost;
            newcost = swap;
        }

        // the distance is the cost for transforming all letters in both strings        
        return cost[len0 - 1];
    }
}
