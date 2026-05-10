import { Component, inject, signal } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ShortenerApiService } from '../services/shortener-api.service';

@Component({
  selector: 'app-home',
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class HomeComponent {
  private readonly fb  = inject(FormBuilder);
  private readonly api = inject(ShortenerApiService);

  protected readonly loading      = signal(false);
  protected readonly shortLink    = signal<string | null>(null);
  protected readonly copied       = signal(false);
  protected readonly errorMsg     = signal<string | null>(null);
  protected readonly showRedirect = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    originalLink: ['', [Validators.required, Validators.pattern('^(https?)://.+$')]],
  });

  protected submit(): void {
    this.errorMsg.set(null);
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }

    this.loading.set(true);
    this.shortLink.set(null);

    this.api.createShortLink({ originalLink: this.form.getRawValue().originalLink }).subscribe({
      next: (res) => { this.shortLink.set(res.shortLink); this.loading.set(false); },
      error: (err: HttpErrorResponse) => {
        this.loading.set(false);
        this.errorMsg.set(err.error?.message ?? 'Could not shorten the URL right now. Please try again.');
      },
    });
  }

  protected copyLink(): void {
    const link = this.shortLink();
    if (!link) return;
    navigator.clipboard.writeText(link).then(() => {
      this.copied.set(true);
      setTimeout(() => this.copied.set(false), 2500);
    });
  }

  protected openLink(): void {
    const link = this.shortLink();
    if (!link) return;
    this.showRedirect.set(true);
    setTimeout(() => { window.location.href = link; }, 2000);
  }
}
