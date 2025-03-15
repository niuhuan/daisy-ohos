mod anime_home;
pub mod api;
mod context;
mod database;
mod download_thread;
mod local;
mod utils;

pub type Result<T> = anyhow::Result<T>;

#[cfg(not(target_family = "wasm"))]
#[napi_ohos::module_init]
fn init() {
    let rt = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .worker_threads(20)
        .thread_keep_alive(std::time::Duration::from_secs(60))
        .max_blocking_threads(10)
        .build()
        .unwrap();
    napi_ohos::bindgen_prelude::create_custom_tokio_runtime(rt);
}
