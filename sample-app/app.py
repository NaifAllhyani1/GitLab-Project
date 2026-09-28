import os
import socket

import psutil
import streamlit as st

from utils import compute_cost, format_uptime, storage_cost, total_cost, uptime_seconds

st.set_page_config(page_title="Deployment Dashboard", layout="wide")

st.title("Deployment Dashboard")
st.caption("This page is tested, built and deployed automatically by GitLab CI/CD")

tab_live, tab_flow, tab_cost = st.tabs(["Live deployment", "Pipeline flow", "Cost estimator"])

with tab_live:
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Version", os.getenv("APP_VERSION", "dev"))
    c2.metric("Commit", os.getenv("GIT_COMMIT", "local")[:8])
    c3.metric("Branch", os.getenv("GIT_BRANCH", "local"))
    c4.metric("Uptime", format_uptime(uptime_seconds()))

    st.write(f"Built at: {os.getenv('BUILD_TIME', 'unknown')}")
    st.write(f"Container: {socket.gethostname()}")

    st.subheader("Server resources")
    usage = {
        "CPU": psutil.cpu_percent(interval=0.5),
        "Memory": psutil.virtual_memory().percent,
        "Disk": psutil.disk_usage("/").percent,
    }
    for name, value in usage.items():
        st.write(f"{name}: {value:.0f}%")
        st.progress(min(int(value), 100) / 100)

    st.button("Refresh")
    st.success("Health endpoint: /_stcore/health")

with tab_flow:
    st.graphviz_chart(
        """
        digraph {
            rankdir=LR;
            node [shape=box, style=rounded];
            Developer -> "GitLab repo" -> Pipeline -> Test -> "Docker build"
                -> "Container registry" -> "Azure VM" -> "Running app" -> "Health check";
        }
        """
    )

with tab_cost:
    left, right = st.columns(2)
    with left:
        hourly = st.number_input("VM price per hour (USD)", min_value=0.0, value=0.10, step=0.01)
        hours = st.slider("Hours per day", 1, 24, 8)
    with right:
        days = st.slider("Days per month", 1, 31, 22)
        disk = st.number_input("Disk size (GB)", min_value=0, max_value=4096, value=30)

    st.metric("Estimated monthly cost", f"${total_cost(hourly, hours, days, disk):,.2f}")
    st.bar_chart(
        {
            "Cost (USD)": {
                "Compute": compute_cost(hourly, hours, days),
                "Storage": storage_cost(disk),
            }
        }
    )