#pragma warning(push, 0)
#pragma warning(disable: 4365)
#include <spdlog/spdlog.h>
#pragma warning(pop)

int main()
{
    spdlog::info("Hello {} !\n", "World");
}
