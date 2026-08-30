import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260826182827 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "homepage_block" ("id" text not null, "type" text not null, "title" text null, "subtitle" text null, "description" text null, "imageUrl" text null, "linkUrl" text null, "ctaLabel" text null, "referenceId" text null, "productIds" jsonb null, "rank" integer not null default 0, "isActive" boolean not null default true, "metadata" jsonb null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "homepage_block_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_homepage_block_deleted_at" ON "homepage_block" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "homepage_block" cascade;`);
  }

}
