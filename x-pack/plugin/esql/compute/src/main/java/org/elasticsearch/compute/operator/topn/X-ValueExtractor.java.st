/*
 * Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
 * or more contributor license agreements. Licensed under the Elastic License
 * 2.0; you may not use this file except in compliance with the Elastic License
 * 2.0.
 */

package org.elasticsearch.compute.operator.topn;

$if(BytesRef)$
import org.apache.lucene.util.BytesRef;
$endif$
import org.apache.lucene.util.BytesRefBuilder;
import org.elasticsearch.compute.data.$Type$Block;
import org.elasticsearch.compute.data.$Type$Vector;

abstract class ValueExtractorFor$Type$ implements ValueExtractor {
    static ValueExtractorFor$Type$ extractorFor(TopNEncoder encoder, boolean inKey, $Type$Block block) {
        $Type$Vector vector = block.asVector();
        if (vector != null) {
            return new ValueExtractorFor$Type$.ForVector(encoder, inKey, vector);
        }
        return new ValueExtractorFor$Type$.ForBlock(encoder, inKey, block);
    }

$if(BytesRef)$
    private final TopNEncoder encoder;

    protected final BytesRef scratch = new BytesRef();
$endif$

    protected final boolean inKey;

    ValueExtractorFor$Type$(TopNEncoder encoder, boolean inKey) {
$if(BytesRef)$
        this.encoder = encoder;
$else$
        assert encoder == TopNEncoder.DEFAULT_UNSORTABLE : encoder.toString();
$endif$
        this.inKey = inKey;
    }

    protected final void writeCount(BytesRefBuilder values, int count) {
        TopNEncoder.DEFAULT_UNSORTABLE.encodeVInt(count, values);
    }

    protected final void actualWriteValue(BytesRefBuilder values, $type$ value) {
$if(BytesRef)$
        encoder.encodeBytesRef(value, values);
$else$
        TopNEncoder.DEFAULT_UNSORTABLE.encode$Type$(value, values);
$endif$
    }

    static class ForVector extends ValueExtractorFor$Type$ {
        private final $Type$Vector vector;

        ForVector(TopNEncoder encoder, boolean inKey, $Type$Vector vector) {
            super(encoder, inKey);
            this.vector = vector;
        }

        @Override
        public void writeValue(BytesRefBuilder values, int position) {
            writeCount(values, 1);
            if (inKey) {
                // will read results from the key
                return;
            }
$if(BytesRef)$
            actualWriteValue(values, vector.get$Type$(position, scratch));
$else$
            actualWriteValue(values, vector.get$Type$(position));
$endif$
        }
    }

    static class ForBlock extends ValueExtractorFor$Type$ {
        private final $Type$Block block;

        ForBlock(TopNEncoder encoder, boolean inKey, $Type$Block block) {
            super(encoder, inKey);
            this.block = block;
        }

        @Override
        public void writeValue(BytesRefBuilder values, int position) {
            int size = block.getValueCount(position);
            writeCount(values, size);
            if (size == 1 && inKey) {
                // Will read results from the key
                return;
            }
            int start = block.getFirstValueIndex(position);
            int end = start + size;
            for (int i = start; i < end; i++) {
$if(BytesRef)$
                actualWriteValue(values, block.getBytesRef(i, scratch));
$else$
                actualWriteValue(values, block.get$Type$(i));
$endif$
            }
        }
    }
}
