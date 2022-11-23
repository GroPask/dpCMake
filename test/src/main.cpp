#include <fmt/core.h>

#include <string>

#include <cstdlib>

int main()
{
    const std::string s = fmt::format("The answer is {}.", 42);
    
    if (s != "The answer is 42.")
        return EXIT_FAILURE;

    return EXIT_SUCCESS;
}

#ifdef DP_CMAKE_TEST_WIN32
#include <Windows.h>

int WinMain(HINSTANCE /*hInstance*/, HINSTANCE /*hPrevInstance*/, PSTR /*lpCmdLine*/, INT /*nCmdShow*/)
{
    return main();
}
#endif
