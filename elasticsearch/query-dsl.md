## Query and filter context

#### Relevance scores

默认情况下，Elasticsearch relavance score 排序，即查询结果中的 _score 字段浮点值，该值越大，表示查询结果越匹配。

score 值的计算取决于他是在 query context 还是 filter context。

#### Query context
在 query context 中，查询语句表示“文档有多匹配查询语句”，然后才是是否匹配到文档。查询语句会计算 _score 的值。

#### Filter context
在 filter context 中，查询语句表示“文档是否匹配查询语句”，回答往往为“是”或者“否”，因此不会计算 _score。

通常情况下，filter 会自动缓存结果，用来加快查询速度。

当语句处于 filter 参数中时，filter context 才会起作用。比如在 bool query 中的 filter 或 must_not 参数；或者 filter aggregation 中的 filter 参数。

