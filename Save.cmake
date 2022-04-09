#set_target_properties(SdlOpenGl3 PROPERTIES WIN32_EXECUTABLE $<IF:$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>,true,false>)



#list(APPEND CMAKE_PROGRAM_PATH "C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/Llvm/x64/bin")
#project_options(ENABLE_CLANG_TIDY)
#set(CMAKE_CXX_CLANG_TIDY "clang-tidy;-checks=*")  
#MESSAGE("CMAKE_CXX_CLANG_TIDY ${CMAKE_CXX_CLANG_TIDY}")

set_target_properties(dpImGuiToolkit PROPERTIES
    VS_GLOBAL_RunCodeAnalysis true

    # Use visual studio core guidelines
    VS_GLOBAL_EnableMicrosoftCodeAnalysis true
    VS_GLOBAL_CodeAnalysisRuleSet ${CMAKE_CURRENT_SOURCE_DIR}/foo.ruleset
    VS_GLOBAL_CodeAnalysisRuleSet ${CMAKE_CURRENT_SOURCE_DIR}/foo.ruleset

    # Use clangtidy
    VS_GLOBAL_EnableClangTidyCodeAnalysis true
    VS_GLOBAL_ClangTidyChecks -checks=-*,modernize-*,-modernize-use-trailing-return-type,-modernize-use-auto
)