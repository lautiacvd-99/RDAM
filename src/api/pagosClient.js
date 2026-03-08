import axios from "axios";

export const pagosClient = axios.create({
  baseURL: import.meta.env.VITE_PAGOS_URL || "http://localhost:3000",
});