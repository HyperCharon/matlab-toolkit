classdef network
%ECALCULATOR.NETWORK 图论与网络分析工具
%
%   ecalculator.network.shortest_path(W, s, t)        最短路径 (Dijkstra)
%   ecalculator.network.floyd_warshall(W)              全源最短路径
%   ecalculator.network.minimum_spanning_tree(W)       最小生成树
%   ecalculator.network.max_flow(C, s, t)              最大流
%   ecalculator.network.centrality(A)                  网络中心性
%
%   See also ecalculator.optimization, ecalculator.statistics

    methods(Static)
        function info = shortest_path(W, source, target)
        %SHORTEST_PATH 最短路径算法 (Dijkstra)
        %
        %   info = ecalculator.network.shortest_path(W, source, target)
        %
        %   输入:
        %     W      - 邻接矩阵 (n x n)，W(i,j) 为边权，Inf 表示无边
        %     source - 起点
        %     target - 终点 (可选，不指定则计算到所有点的最短路径)
        %
        %   输出:
        %     info.dist    - 最短距离
        %     info.path    - 最短路径
        %     info.distances - 到所有点的距离
        %
        %   示例:
        %     W = [0 1 4 Inf; 1 0 2 6; 4 2 0 3; Inf 6 3 0];
        %     info = ecalculator.network.shortest_path(W, 1, 4)

            n = size(W, 1);

            % 参数验证
            if size(W, 2) ~= n
                error('ecalculator:network:notSquare', '邻接矩阵必须是方阵');
            end

            % Dijkstra 算法
            dist = inf(n, 1);
            dist(source) = 0;
            prev = zeros(n, 1);
            visited = false(n, 1);

            for iter = 1:n
                % 找未访问的最小距离节点
                min_dist = inf;
                u = -1;
                for i = 1:n
                    if ~visited(i) && dist(i) < min_dist
                        min_dist = dist(i);
                        u = i;
                    end
                end

                if u == -1
                    break;
                end

                visited(u) = true;

                % 更新邻居距离
                for v = 1:n
                    if ~visited(v) && W(u, v) < inf
                        new_dist = dist(u) + W(u, v);
                        if new_dist < dist(v)
                            dist(v) = new_dist;
                            prev(v) = u;
                        end
                    end
                end
            end

            % 回溯路径 (使用 cell 数组避免动态增长)
            if nargin >= 3 && target > 0
                path_cell = {};
                node = target;
                while node > 0
                    path_cell = [{node}, path_cell];
                    node = prev(node);
                end
                path = cell2mat(path_cell);

                fprintf('📊 最短路径 (Dijkstra):\n');
                fprintf('   起点: %d, 终点: %d\n', source, target);
                fprintf('   最短距离: %.2f\n', dist(target));
                fprintf('   路径: %s\n', mat2str(path));

                info.dist = dist(target);
                info.path = path;
            else
                fprintf('📊 最短路径 (Dijkstra):\n');
                fprintf('   起点: %d\n', source);
                for i = 1:n
                    fprintf('   到节点 %d: %.2f\n', i, dist(i));
                end

                info.dist = [];
                info.path = [];
            end

            info.distances = dist;
            info.prev = prev;
        end

        function info = floyd_warshall(W)
        %FLOYD_WARSHALL 全源最短路径 (Floyd-Warshall)
        %
        %   info = ecalculator.network.floyd_warshall(W)
        %
        %   输入:
        %     W - 邻接矩阵 (n x n)
        %
        %   输出:
        %     info.dist_matrix - 距离矩阵
        %     info.next        - 路径矩阵
        %
        %   示例:
        %     W = [0 1 4 Inf; 1 0 2 6; 4 2 0 3; Inf 6 3 0];
        %     info = ecalculator.network.floyd_warshall(W)

            n = size(W, 1);
            dist = W;
            next = zeros(n);

            % 初始化 next 矩阵
            for i = 1:n
                for j = 1:n
                    if i ~= j && W(i,j) < inf
                        next(i,j) = j;
                    end
                end
            end

            % Floyd-Warshall 算法
            for k = 1:n
                for i = 1:n
                    for j = 1:n
                        if dist(i,k) + dist(k,j) < dist(i,j)
                            dist(i,j) = dist(i,k) + dist(k,j);
                            next(i,j) = next(i,k);
                        end
                    end
                end
            end

            fprintf('📊 全源最短路径 (Floyd-Warshall):\n');
            fprintf('   节点数: %d\n', n);
            fprintf('   距离矩阵:\n');
            for i = 1:n
                fprintf('   ');
                for j = 1:n
                    if dist(i,j) == inf
                fprintf('   Inf ');
            else
                fprintf(' %5.1f ', dist(i,j));
            end
                end
                fprintf('\n');
            end

            info.dist_matrix = dist;
            info.next = next;
        end

        function info = minimum_spanning_tree(W)
        %MINIMUM_SPANNING_TREE 最小生成树 (Kruskal)
        %
        %   info = ecalculator.network.minimum_spanning_tree(W)
        %
        %   输入:
        %     W - 邻接矩阵 (n x n)
        %
        %   输出:
        %     info.edges - 最小生成树的边 [u, v, weight]
        %     info.total_weight - 总权重
        %
        %   示例:
        %     W = [0 2 Inf 6; 2 0 3 Inf; Inf 3 0 4; 6 Inf 4 0];
        %     info = ecalculator.network.minimum_spanning_tree(W)

            n = size(W, 1);

            % 提取所有边 (预分配内存)
            max_edges = n * (n-1) / 2;
            edges = zeros(max_edges, 3);
            edge_count = 0;
            for i = 1:n
                for j = i+1:n
                    if W(i,j) < inf
                        edge_count = edge_count + 1;
                        edges(edge_count, :) = [i, j, W(i,j)];
                    end
                end
            end
            edges = edges(1:edge_count, :);

            % 按权重排序
            [~, idx] = sort(edges(:,3));
            edges = edges(idx, :);

            % Kruskal 算法 (并查集)
            parent = 1:n;
            rank = zeros(1, n);

            mst_edges = zeros(n-1, 3);
            mst_count = 0;
            total_weight = 0;

            for i = 1:size(edges, 1)
                u = edges(i, 1);
                v = edges(i, 2);
                w = edges(i, 3);

                % 查找根节点
                root_u = find_root(parent, u);
                root_v = find_root(parent, v);

                if root_u ~= root_v
                    mst_count = mst_count + 1;
                    mst_edges(mst_count, :) = [u, v, w];
                    total_weight = total_weight + w;

                    % 合并集合
                    if rank(root_u) < rank(root_v)
                        parent(root_u) = root_v;
                    elseif rank(root_u) > rank(root_v)
                        parent(root_v) = root_u;
                    else
                        parent(root_v) = root_u;
                        rank(root_u) = rank(root_u) + 1;
                    end
                end
            end
            mst_edges = mst_edges(1:mst_count, :);

            fprintf('📊 最小生成树 (Kruskal):\n');
            fprintf('   节点数: %d\n', n);
            fprintf('   边数:   %d\n', size(mst_edges, 1));
            fprintf('   总权重: %.2f\n', total_weight);
            fprintf('   ───── 边列表 ─────\n');
            for i = 1:size(mst_edges, 1)
                fprintf('   %d -- %d : %.2f\n', mst_edges(i,1), mst_edges(i,2), mst_edges(i,3));
            end

            info.edges = mst_edges;
            info.total_weight = total_weight;
            info.n_edges = size(mst_edges, 1);
        end

        function info = max_flow(C, source, sink)
        %MAX_FLOW 最大流算法 (Ford-Fulkerson)
        %
        %   info = ecalculator.network.max_flow(C, source, sink)
        %
        %   输入:
        %     C      - 容量矩阵 (n x n)
        %     source - 源点
        %     sink   - 汇点
        %
        %   输出:
        %     info.max_flow  - 最大流量
        %     info.flow      - 流量矩阵
        %     info.min_cut   - 最小割
        %
        %   示例:
        %     C = [0 16 13 0 0 0; 0 0 10 12 0 0; 0 4 0 0 14 0;
        %          0 0 9 0 0 20; 0 0 0 7 0 4; 0 0 0 0 0 0];
        %     info = ecalculator.network.max_flow(C, 1, 6)

            n = size(C, 1);
            flow = zeros(n);
            residual = C;

            max_flow_value = 0;

            while true
                % BFS 找增广路径
                [path, bottleneck] = bfs_path(residual, source, sink);

                if isempty(path)
                    break;
                end

                % 更新残余网络
                for i = 1:length(path)-1
                    u = path(i);
                    v = path(i+1);
                    residual(u, v) = residual(u, v) - bottleneck;
                    residual(v, u) = residual(v, u) + bottleneck;
                    flow(u, v) = flow(u, v) + bottleneck;
                end

                max_flow_value = max_flow_value + bottleneck;
            end

            % 找最小割 (从源点可达的节点)
            visited = false(n, 1);
            queue = source;
            visited(source) = true;
            queue_head = 1;
            while queue_head <= numel(queue)
                u = queue(queue_head);
                queue_head = queue_head + 1;
                for v = 1:n
                    if ~visited(v) && residual(u, v) > 0
                        visited(v) = true;
                        queue(end+1) = v;  %#ok<AGROW>
                    end
                end
            end

            min_cut_S = find(visited);
            min_cut_T = find(~visited);

            fprintf('📊 最大流 (Ford-Fulkerson):\n');
            fprintf('   源点: %d, 汇点: %d\n', source, sink);
            fprintf('   最大流量: %.2f\n', max_flow_value);
            fprintf('   最小割: S={%s}, T={%s}\n', ...
                mat2str(min_cut_S), mat2str(min_cut_T));

            info.max_flow = max_flow_value;
            info.flow = flow;
            info.min_cut_S = min_cut_S;
            info.min_cut_T = min_cut_T;
        end

        function info = centrality(A)
        %CENTRALITY 网络中心性分析
        %
        %   info = ecalculator.network.centrality(A)
        %
        %   输入:
        %     A - 邻接矩阵 (无向图)
        %
        %   输出:
        %     info.degree     - 度中心性
        %     info.closeness  - 接近中心性
        %     info.betweenness - 介数中心性
        %
        %   示例:
        %     A = [0 1 1 0; 1 0 1 1; 1 1 0 0; 0 1 0 0];
        %     info = ecalculator.network.centrality(A)

            n = size(A, 1);

            % 度中心性
            degree = sum(A, 2) / (n - 1);

            % 接近中心性
            dist_matrix = A;
            dist_matrix(dist_matrix == 0) = inf;
            for i = 1:n
                dist_matrix(i,i) = 0;
            end

            % Floyd-Warshall 计算距离
            for k = 1:n
                for i = 1:n
                    for j = 1:n
                        if dist_matrix(i,k) + dist_matrix(k,j) < dist_matrix(i,j)
                            dist_matrix(i,j) = dist_matrix(i,k) + dist_matrix(k,j);
                        end
                    end
                end
            end

            closeness = zeros(n, 1);
            for i = 1:n
                reachable = dist_matrix(i, :) < inf;
                reachable(i) = false;
                if any(reachable)
                    closeness(i) = sum(reachable) / sum(dist_matrix(i, reachable));
                end
            end

            % 介数中心性
            betweenness = zeros(n, 1);
            for s = 1:n
                for t = s+1:n
                    % 找所有最短路径
                    paths = find_all_shortest_paths(dist_matrix, s, t);
                    for p = 1:length(paths)
                        path = paths{p};
                        for i = 2:length(path)-1
                            betweenness(path(i)) = betweenness(path(i)) + 1;
                        end
                    end
                end
            end
            betweenness = betweenness / ((n-1)*(n-2)/2);

            fprintf('📊 网络中心性分析:\n');
            fprintf('   节点数: %d\n', n);
            fprintf('   ───── 中心性排名 ─────\n');

            [~, rank] = sort(betweenness, 'descend');
            for i = 1:min(n, 5)
                idx = rank(i);
                fprintf('   第 %d 名: 节点 %d (度=%.3f, 接近=%.3f, 介数=%.3f)\n', ...
                    i, idx, degree(idx), closeness(idx), betweenness(idx));
            end

            info.degree = degree;
            info.closeness = closeness;
            info.betweenness = betweenness;
        end
    end
end

% 辅助函数
function root = find_root(parent, node)
    while parent(node) ~= node
        node = parent(node);
    end
    root = node;
end

function [path, bottleneck] = bfs_path(C, source, sink)
    n = size(C, 1);
    visited = false(n, 1);
    parent = zeros(n, 1);
    visited(source) = true;
    queue = source;

    while ~isempty(queue)
        u = queue(1);
        queue(1) = [];

        for v = 1:n
            if ~visited(v) && C(u, v) > 0
                visited(v) = true;
                parent(v) = u;
                queue = [queue, v];

                if v == sink
                    % 回溯路径
                    path = sink;
                    node = sink;
                    bottleneck = inf;
                    while node ~= source
                        prev_node = parent(node);
                        bottleneck = min(bottleneck, C(prev_node, node));
                        path = [prev_node, path];
                        node = prev_node;
                    end
                    return;
                end
            end
        end
    end

    path = [];
    bottleneck = 0;
end

function paths = find_all_shortest_paths(dist, s, t)
    % 简化实现: 返回单条最短路径
    n = size(dist, 1);
    path = s;
    current = s;

    while current ~= t
        next_node = -1;
        min_dist = inf;
        for j = 1:n
            if dist(current, j) + dist(j, t) == dist(current, t) && ...
               dist(current, j) < inf && j ~= current
                if dist(current, j) < min_dist
                    min_dist = dist(current, j);
                    next_node = j;
                end
            end
        end

        if next_node == -1
            paths = {};
            return;
        end

        path = [path, next_node];
        current = next_node;
    end

    paths = {path};
end
