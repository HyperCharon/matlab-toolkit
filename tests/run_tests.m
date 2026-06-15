function results = run_tests()
%RUN_TESTS 运行所有 MatForge 单元测试
%
%   results = run_tests();
%
%   See also matlab.unittest.TestSuite

    fprintf('🧪 MatForge 单元测试\n');
    fprintf('========================\n\n');

    % 添加路径
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));

    % 发现测试
    suite = matlab.unittest.TestSuite.fromFolder(fileparts(mfilename('fullpath')));

    fprintf('找到 %d 个测试\n\n', numel(suite));

    % 运行测试
    runner = matlab.unittest.TestRunner.withTextOutput('Verbosity', 3);
    results = runner.run(suite);

    % 打印摘要
    fprintf('\n========================\n');
    fprintf('📊 测试结果:\n');
    fprintf('   总数: %d\n', numel(results));
    fprintf('   通过: %d\n', sum([results.Passed]));
    fprintf('   失败: %d\n', sum([results.Failed]));
    fprintf('   跳过: %d\n', sum([results.Skipped]));

    if all([results.Passed])
        fprintf('\n✅ 所有测试通过!\n');
    else
        fprintf('\n❌ 有测试失败!\n');
    end
end
