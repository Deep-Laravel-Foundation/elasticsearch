/*
 * Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
 * or more contributor license agreements. Licensed under the Elastic License
 * 2.0; you may not use this file except in compliance with the Elastic License
 * 2.0.
 */

package org.elasticsearch.compute.operator.topn;

import org.apache.lucene.util.BytesRef;
import org.elasticsearch.compute.data.Block;

public class ResultBuilderForNull implements ResultBuilder {
    private int positions;

    @Override
    public void decodeKey(BytesRef keys) {
        throw new AssertionError("somehow got a value for a null key");
    }

    @Override
    public void decodeValue(BytesRef values) {
        int size = TopNEncoder.DEFAULT_UNSORTABLE.decodeVInt(values);
        if (size != 0) {
            throw new IllegalArgumentException("null columns should always have 0 entries");
        }
        positions++;
    }

    @Override
    public Block build() {
        return Block.constantNullBlock(positions);
    }

    @Override
    public String toString() {
        return "ValueExtractorForNull";
    }
}
