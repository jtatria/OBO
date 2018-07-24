package edu.columbia.incite.obo;

import edu.columbia.incite.Conf;
import edu.columbia.incite.Lector;

import java.io.IOException;
import java.nio.file.Path;

import edu.columbia.incite.obo.corpus.POBDocFields;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.apache.lucene.index.Term;
import org.apache.lucene.search.AutomatonQuery;
import org.apache.lucene.search.BooleanClause.Occur;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.util.BytesRef;
import org.apache.lucene.util.automaton.Automata;

import edu.columbia.incite.obo.corpus.Samples;
import edu.columbia.incite.corpus.DocSet;
import edu.columbia.incite.run.Logs;

/**
 *
 * @author José Tomás Atria <jtatria at gmail.com>
 */
public class Epochs {

    public static final Map<String,Query> EPOCHS;
    static {
        Map<String,Query> tmp = new HashMap<>();
        tmp.put( "e01_1674_1697", epoch( 1674, 1697 ) );
        tmp.put( "e02_1686_1709", epoch( 1686, 1709 ) );
        tmp.put( "e03_1698_1721", epoch( 1698, 1721 ) );
        tmp.put( "e04_1710_1733", epoch( 1710, 1733 ) );
        tmp.put( "e05_1722_1745", epoch( 1722, 1745 ) );
        tmp.put( "e06_1734_1757", epoch( 1734, 1757 ) );
        tmp.put( "e07_1746_1769", epoch( 1746, 1769 ) );
        tmp.put( "e08_1758_1781", epoch( 1758, 1781 ) );
        tmp.put( "e09_1770_1793", epoch( 1770, 1793 ) );
        tmp.put( "e10_1782_1805", epoch( 1782, 1805 ) );
        tmp.put( "e11_1794_1817", epoch( 1794, 1817 ) );
        tmp.put( "e12_1806_1829", epoch( 1806, 1829 ) );
        tmp.put( "e13_1818_1841", epoch( 1818, 1841 ) );
        tmp.put( "e14_1830_1853", epoch( 1830, 1853 ) );
        tmp.put( "e15_1842_1865", epoch( 1842, 1865 ) );
        tmp.put( "e16_1854_1877", epoch( 1854, 1877 ) );
        tmp.put( "e17_1866_1889", epoch( 1866, 1889 ) );
        tmp.put( "e18_1878_1901", epoch( 1878, 1901 ) );
        tmp.put( "e19_1890_1913", epoch( 1890, 1913 ) );
        EPOCHS = Collections.unmodifiableMap( tmp );
    }

    public static Query epoch( int t0, int t1 ) {
        List<BytesRef> years = IntStream.rangeClosed( t0, t1 ).mapToObj(
            i -> Integer.toString( i )
        ).map(
            s -> new BytesRef( s )
        ).collect( Collectors.toList() );
        return new AutomatonQuery(
            new Term( POBDocFields.OBO_YEAR_FIELD, "" ),
            Automata.makeStringUnion( years )
        );
    }

    public static void main( String[] args ) throws IOException {
        Conf conf = new Conf();
        conf.set( Conf.PARAM_HOME_DIR, "/home/jta/desktop/obo" );
        Lector obo = new Lector( conf );
        IndexSearcher is = new IndexSearcher( obo.indexReader() );

        obo.mapField( conf.fieldSplit() );
        obo.lexicon();

        Path root = conf.dataDir().resolve( "samples" );
        
        DocSet ds;
        
        Logs.infof( "====== Building global corpus ======" );
        obo.conf().set( Conf.PARAM_DATA_DIR, root.toString() );
        ds = Samples.getSample( obo.indexReader(), Samples.TESTIMONY );
        obo.dumpFrequencies( obo.countFrequencies( ds ) );
        obo.dumpPOSCounts( obo.countPOSTags( ds ) );
        obo.dumpCooccurrences( obo.countCooccurrences( ds ) );

        Logs.infof( "====== Building epoch corpora ======" );
        for( String epoch : EPOCHS.keySet() ) {
            obo.conf().set( Conf.PARAM_DATA_DIR, root.resolve( epoch ).toString() );
            Query q = ( new BooleanQuery.Builder() ).add(
                Samples.TESTIMONY, Occur.FILTER
            ).add(
                EPOCHS.get( epoch ), Occur.FILTER
            ).build();
            TopDocs hits = is.search( q, obo.indexReader().numDocs() );
            ds = new DocSet( hits, obo.indexReader().numDocs() );
            Logs.infof(
                "Epoch %s: sample contains %d documents. Gathering data...",
                epoch, ds.size()
            );
            obo.dumpFrequencies( obo.countFrequencies( ds ) );
            obo.dumpPOSCounts( obo.countPOSTags( ds ) );
            obo.dumpCooccurrences( obo.countCooccurrences( ds ) );
            Logs.infof( "" );
        }
    }
}
